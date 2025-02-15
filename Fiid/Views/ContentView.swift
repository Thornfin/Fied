//
//  ContentView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-28.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var isShowingSplashScreen = true
    @State private var isShowingDetail = false
    @State private var isShowingSearch = false
    @State private var searchText: String = ""
    @State private var selectedFilters: Set<FilterOption> = []
    @State private var selectedRestaurant: Restaurant? = nil
    @FocusState private var isSearchFocused: Bool

    // ViewModels
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantViewModel = RestaurantViewModel()

    // Track user location
    @State private var userLocation: CLLocationCoordinate2D?

    // Debounced fetch task
    @State private var fetchTask: DispatchWorkItem?

    // MARK: - Filter & Search Logic
    /// Returns the final list of restaurants after applying search, filters, optional distance or review sorting, then pushing "no image" to bottom.
    var filteredRestaurants: [Restaurant] {
        var restaurants = restaurantViewModel.restaurants

        // 1) Search text filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let normalizedSearchText = searchText
                .lowercased()
                .filter { !$0.isWhitespace }

            restaurants = restaurants.filter { r in
                let normName = r.name.lowercased().filter { !$0.isWhitespace }
                return normName.contains(normalizedSearchText)
            }
        }

        // 2) Apply filters (like Halal, Vegan, etc.) but skip .distance, .reviews, .clear
        if !selectedFilters.isEmpty {
            for filter in selectedFilters {
                if filter == .distance || filter == .reviews || filter == .clear {
                    continue
                }
                restaurants = restaurants.filter { filter.predicate(for: $0) }
            }
        }

        // 3) Sort by distance if user selected .distance
        if selectedFilters.contains(.distance) {
            restaurants.sort {
                ($0.distance ?? .greatestFiniteMagnitude)
                < ($1.distance ?? .greatestFiniteMagnitude)
            }
        }

        // 4) Sort by reviews (rating desc) if user selected .reviews
        if selectedFilters.contains(.reviews) {
            restaurants.sort {
                ($0.rating ?? 0) > ($1.rating ?? 0)
            }
        }

        // 5) Always push restaurants with no images to bottom
        restaurants = stableSortByImagePresence(restaurants)

        return restaurants
    }

    /// Moves restaurants with images to top (in stable manner), and no-image restaurants to the bottom, preserving prior order otherwise.
    func stableSortByImagePresence(_ list: [Restaurant]) -> [Restaurant] {
        let enumerated = list.enumerated().map { (idx, rest) in (idx, rest) }
        let sorted = enumerated.sorted { a, b in
            let hasImageA = !(a.1.imageUrls.isEmpty)
            let hasImageB = !(b.1.imageUrls.isEmpty)

            // If both have or both lack images, preserve original order
            if hasImageA == hasImageB {
                return a.0 < b.0
            }
            // If only A has images => A goes first
            return hasImageA && !hasImageB
        }
        return sorted.map { $0.1 }
    }

    // Splitting the final list into rows of 3
    var restaurantRows: [[Restaurant]] {
        filteredRestaurants.chunked(into: 3)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color.white.ignoresSafeArea()

                    // Check authorization
                    let status = locationManager.authorizationStatus
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways:
                        mainContentView
                    case .denied, .restricted:
                        Text("Location access is denied. Please enable it in settings.")
                            .padding()
                    default:
                        // Request location
                        ProgressView("Requesting location access...")
                            .onAppear {
                                locationManager.requestLocation()
                            }
                    }
                }
                .onAppear {
                    locationManager.requestLocation()
                    if let loc = locationManager.location?.coordinate {
                        fetchRestaurantsDebounced(for: loc)
                    }
                }
                .onReceive(locationManager.$location) { loc in
                    if let coordinate = loc?.coordinate {
                        userLocation = coordinate
                        fetchRestaurantsDebounced(for: coordinate)
                        // Hide splash screen once location is known
                        withAnimation(.easeOut(duration: 1.0)) {
                            isShowingSplashScreen = false
                        }
                    }
                }
            }

            // Splash Screen
            if isShowingSplashScreen {
                FiedView() // Your custom splash screen
                    .zIndex(1)
            }
        }
    }

    // MARK: - Main Content
    private var mainContentView: some View {
        VStack {
            if !filteredRestaurants.isEmpty {
                // Show restaurant results
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(restaurantRows.indices, id: \.self) { rowIndex in
                            let rowRestaurants = restaurantRows[rowIndex]
                            HStack(spacing: 8) {
                                ForEach(rowRestaurants) { restaurant in
                                    RestaurantsMainMenu(
                                        restaurant: restaurant,
                                        isSelected: selectedRestaurant?.id == restaurant.id,
                                        onSelect: { handleRestaurantSelection(restaurant) },
                                        userLocation: userLocation
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .onTapGesture {
                    isSearchFocused = false // Dismiss keyboard
                }
                .padding(.bottom, 0)

            } else if isShowingSearch {
                Spacer()
                Text("No restaurants are available...")
                    .foregroundStyle(.gray)
                    .padding()
                Spacer()

            } else {
                Spacer()
                Text("No restaurants are available...")
                    .foregroundStyle(.gray)
                    .padding()
                Spacer()
            }
        }
        .safeAreaInset(edge: .top) {
            // Location Bar
            LocationBarView(
                restaurantViewModel: restaurantViewModel,
                isShowingDetail: $isShowingDetail,
                isShowingSearch: $isShowingSearch,
                searchText: $searchText,
                selectedFilters: $selectedFilters,
                selectedRestaurant: $selectedRestaurant
            )
            .focused($isSearchFocused)
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom bar
            if !isSearchFocused {
                BottomBarNavigationView(
                    isShowingSearch: $isShowingSearch,
                    selectedRestaurant: $selectedRestaurant,
                    restaurantViewModel: restaurantViewModel
                )
            }
        }
        // Filter sheet
        .sheet(isPresented: $isShowingDetail) {
            FilterView(
                isShowingDetail: $isShowingDetail,
                selectedFilters: $selectedFilters
            )
            .presentationDetents([.fraction(0.5), .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Fetch Debounced
    func fetchRestaurantsDebounced(for location: CLLocationCoordinate2D) {
        fetchTask?.cancel()
        fetchTask = DispatchWorkItem {
            restaurantViewModel.searchNearbyRestaurants(location: location)
            // We do NOT sort or randomize here by default => keep server order
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: fetchTask!)
    }

    // MARK: - Selection
    func handleRestaurantSelection(_ restaurant: Restaurant) {
        if selectedRestaurant?.id == restaurant.id {
            selectedRestaurant = nil
        } else {
            selectedRestaurant = restaurant
            isShowingSearch = false
            restaurantViewModel.enrichRestaurant(restaurant)
        }
    }
}

// MARK: - Helper Extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var chunks: [[Element]] = []
        var index = startIndex
        while index < endIndex {
            let chunkEnd = index.advanced(by: size)
            let chunk = Array(self[index..<Swift.min(chunkEnd, endIndex)])
            chunks.append(chunk)
            index = chunkEnd
        }
        return chunks
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(LanguageManager())
}

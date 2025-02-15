//
//  LocationBarView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import SwiftUI
import MapKit

// MARK: - LocationBarView
struct LocationBarView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.openURL) private var openURLAction
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var restaurantViewModel = RestaurantViewModel()
    
    @Binding var isShowingDetail: Bool
    @Binding var isShowingSearch: Bool
    @Binding var searchText: String
    @Binding var selectedFilters: Set<FilterOption>
    @Binding var selectedRestaurant: Restaurant?
    
    var body: some View {
        VStack {
            topBar
            
            if isShowingSearch {
                searchBar
            }

            // Selected restaurant card (if any)
            if let restaurant = selectedRestaurant {
                SelectedRestaurantCard(
                    restaurant: restaurant,
                    selectedFilters: selectedFilters,
                    openURL: { url in
                        openURLAction(url)
                    }
                )
                .transition(.opacity)
            }
        }
        .bold()
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("DarkGreen"))
        .onAppear {
            locationManager.requestLocation()
            if let location = locationManager.location?.coordinate {
                restaurantViewModel.searchNearbyRestaurants(location: location)
            }
        }
    }
    
    // MARK: - Subviews
    private var topBar: some View {
        HStack(alignment: .center) {
            Spacer()
            
            // Placeholder for some other button in the center
            Button(action: {}) { }

            Spacer()

            VStack {
                if locationManager.placeName != "Unknown" {
                    Text(locationManager.placeName)
                        .foregroundColor(.white)
                } else {
                    Text(languageManager.translate("Fetching location..."))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 50)

            Spacer()

            Button(action: {
                isShowingDetail.toggle()
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
        }
        .bold()
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var searchBar: some View {
        VStack {
            HStack {
                // Back arrow to close search
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isShowingSearch = false
                        searchText = ""
                    }
                }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                }
                .padding(.trailing, 10)
                
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text(languageManager.translate("Search for restaurants..."))
                        .foregroundColor(.gray)
                )
                .foregroundColor(.black)
                .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(30)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}

// MARK: - SelectedRestaurantCard
private struct SelectedRestaurantCard: View {
    let restaurant: Restaurant
    let selectedFilters: Set<FilterOption>
    
    /// Called by the child to open an external URL
    let openURL: (URL) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                // 1) Name
                Text(restaurant.name)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .truncationMode(.tail)

                // 2) Filter icons
                HStack(spacing: 5) {
                    ForEach(Array(selectedFilters), id: \.self) { filter in
                        if filter.predicate(for: restaurant) {
                            FilterButton(
                                symbol: filter,
                                selectedFilters: .constant([]),
                                iconSize: 20,
                                showText: false,
                                showBackgroundCircle: false,
                                unselectedColor: Color("DarkGreen")
                            )
                            .frame(width: 20, height: 20)
                            .padding(.top, 5)
                        }
                    }
                }
                
                // 3) Action buttons (Directions, Reviews, Website)
                HStack(spacing: 30) {
                    // Directions
                    if let lat = restaurant.latitude, let lon = restaurant.longitude {
                        Button(action: {
                            openPreferredMap(for: restaurant)
                        }) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Google Reviews (Always show)
                    Button(action: {
                        openGoogleReviews(for: restaurant.name)
                    }) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    // Website
                    if let url = restaurant.url {
                        Button(action: {
                            openURL(url)
                        }) {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
                .scaleEffect(1.5)
                .padding(.vertical)
            }
            .padding(.horizontal, 30)
            .foregroundColor(.white)
            
            Spacer()
            
            // 4) Restaurant image or default
            if let imageUrl = restaurant.imageUrls.first {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10.0)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
                .padding(.trailing, 10)
            } else {
                Image(systemName: "fork.knife.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .cornerRadius(10.0)
                    .padding(.trailing, 10)
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Color("DarkGreen").opacity(0.8))
        .cornerRadius(10)
    }
    
    // MARK: - Helper Functions

    /// 1) Tries Google Maps x-callback (so user can come back),
    /// 2) Falls back to regular Google Maps link,
    /// 3) Falls back to Apple Maps if user doesn't have Google Maps installed.
    private func openPreferredMap(for restaurant: Restaurant) {
        guard let lat = restaurant.latitude, let lon = restaurant.longitude else { return }

        // Read user preference. Default to "Apple Maps" if not stored.
        let userPreference = UserDefaults.standard.string(forKey: "MapChoice") ?? MapChoice.appleMaps.rawValue
        
        // If user chose Google Maps
        if userPreference == MapChoice.googleMaps.rawValue {
            // 1) Try x-callback (return to 'fied://' after directions)
            let xCallbackURLString = "comgooglemaps-x-callback://?daddr=\(lat),\(lon)&directionsmode=driving&x-success=fied://"
            
            if let xCallbackURL = URL(string: xCallbackURLString),
               UIApplication.shared.canOpenURL(xCallbackURL) {
                UIApplication.shared.open(xCallbackURL)
                return
            }
            
            // 2) Fallback to normal 'comgooglemaps://'
            let normalGoogleMapsString = "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving"
            if let googleMapsURL = URL(string: normalGoogleMapsString),
               UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL)
                return
            }
        }
        
        // 3) Fallback to Apple Maps
        let coords = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coords)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    /// Open Google Maps (or Safari) to show restaurant reviews
    private func openGoogleReviews(for restaurantName: String) {
        let query = restaurantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? restaurantName
        let googleMapsAppURLString = "comgooglemaps://?q=\(query)"
        let googleMapsWebURLString = "https://www.google.com/maps/search/?api=1&query=\(query)"
        
        if let googleMapsAppURL = URL(string: googleMapsAppURLString),
           UIApplication.shared.canOpenURL(googleMapsAppURL) {
            UIApplication.shared.open(googleMapsAppURL)
        } else if let webURL = URL(string: googleMapsWebURLString) {
            UIApplication.shared.open(webURL)
        } else {
            print("Could not open Google Maps or Safari.")
        }
    }
}
struct LocationBarView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleReview = RestaurantReview(
            author_name: "John Doe",
            rating: 4.5,
            text: "Great place with delicious food!",
            time: 1634083200
        )
        
        let sampleRestaurant = Restaurant(
            id: "example",
            name: "Sample Restaurant",
            rating: 4.0,
            imageUrls: [URL(string: "https://via.placeholder.com/100")!],
            street: "Main Street",
            streetNumber: "123",
            latitude: 37.7749,
            longitude: -122.4194,
            phoneNumber: "123-456-7890",
            url: URL(string: "https://www.example.com"),
            distance: nil,
            reviews: [sampleReview],
            isHalal: true,
            isVegan: true,
            isVegetarian: false,
            isHealthy: false,
            isFancy: false,
            isAesthetic: false,
            servesCoffee: false,
            isCheap: false,
            servesPastry: false
        )

        LocationBarView(
            isShowingDetail: .constant(false),
            isShowingSearch: .constant(true),
            searchText: .constant("Sushi"),
            selectedFilters: .constant([.halal, .vegan]),
            selectedRestaurant: .constant(sampleRestaurant)
        )
        .environmentObject(LanguageManager())
        .previewLayout(.sizeThatFits)
    }
}


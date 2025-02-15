//
//  RandomRestaurantView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-19.
//

import SwiftUI
import MapKit

enum ScreenState {
    case initial
    case loading
    case results
}

struct RandomRestaurantView: View {
    @State private var randomRestaurants: [Restaurant] = []
    @State private var screenState: ScreenState = .initial
    @Namespace private var animationNamespace // For matched geometry effect
    @Environment(\.dismiss) private var dismiss // For dismissing the view
    @EnvironmentObject var languageManager: LanguageManager
    
    @Binding var selectedRestaurant: Restaurant?
    
    let restaurants: [Restaurant]
    
    // Use @Environment to handle URL opening without a helper function
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            switch screenState {
            case .initial:
                initialView
            case .loading:
                WaveCirclesView()
            case .results:
                resultsView
            }
        }
        .navigationBarTitle(screenState == .results ? languageManager.translate("Restaurants") : "", displayMode: .inline)
        .navigationBarHidden(screenState == .loading)
        .navigationBarBackButtonHidden(screenState == .results || screenState == .initial)
        .toolbar {
            if screenState == .results || screenState == .initial {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(screenState == .initial ? .white : .gray)
                            .bold()
                    }
                }
            }
        }
        .animation(.easeInOut, value: screenState)
    }
    
    var backgroundColor: Color {
        switch screenState {
        case .initial, .loading:
            return Color("DarkGreen")
        case .results:
            return Color.white
        }
    }
    
    var initialView: some View {
        VStack {
            Spacer()
            Text(languageManager.translate("Feeling Hungry?"))
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text(languageManager.translate("Let us pick something for you!"))
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.bottom)
            
            Button(action: {
                debouncedAction { randomizeRestaurants() }
            }) {
                Text(languageManager.translate("Surprise Me!"))
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            Spacer()
        }
    }
    
    var resultsView: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(randomRestaurants) { restaurant in
                        RestaurantCardView(restaurant: restaurant, namespace: animationNamespace)
                            .padding(.horizontal)
                            .onTapGesture {
                                selectRestaurant(restaurant)
                            }
                    }
                }
            }
            .background(Color.white)
            
            // Reroll Button
            Button(action: {
                debouncedAction { rerollRestaurants() }
            }) {
                Text(languageManager.translate("Reroll"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .background(Color.white)
    }
    
    func randomizeRestaurants() {
        withAnimation {
            screenState = .loading
        }
        
        // Simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            randomRestaurants = Array(restaurants.shuffled().prefix(5))
            withAnimation {
                screenState = .results
            }
        }
    }
    
    func rerollRestaurants() {
        withAnimation {
            screenState = .loading
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                randomRestaurants = Array(restaurants.shuffled().prefix(5))
            }
            
            // Transition back to results view after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    screenState = .results
                }
            }
        }
    }
    
    func selectRestaurant(_ restaurant: Restaurant) {
        selectedRestaurant = restaurant
        withAnimation {
            screenState = .initial
        }
    }
    
    func debouncedAction(_ action: @escaping () -> Void) {
        guard screenState != .loading else {
            print(languageManager.translate("Action disabled: currently loading."))
            return
        }
        
        action()
    }
}

// MARK: - PreviewProvider

struct RandomRestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRestaurants = [
            Restaurant(
                id: UUID().uuidString,
                name: "Poulet Rouge",
                rating: 4.7,
                imageUrls: [URL(string: "https://via.placeholder.com/150")!],
                street: "Main St",
                streetNumber: "123",
                latitude: 45.5017,
                longitude: -73.5673,
                phoneNumber: "123-456-7890",
                url: URL(string: "https://www.pouletrouge.com"),
                reviews: []
            ),
            Restaurant(
                id: UUID().uuidString,
                name: "Paname",
                rating: 4.5,
                imageUrls: [URL(string: "https://via.placeholder.com/150")!],
                street: "Broadway",
                streetNumber: "456",
                latitude: 45.5017,
                longitude: -73.5673,
                phoneNumber: "987-654-3210",
                url: URL(string: "https://www.paname.com"),
                reviews: []
            )
        ]
        
        
        return RandomRestaurantView(
            selectedRestaurant: .constant(nil),
            restaurants: sampleRestaurants
        )
        .environmentObject(LanguageManager())
    }
}

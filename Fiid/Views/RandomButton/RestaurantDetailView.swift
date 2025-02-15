//
//  RestaurantDetailView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-19.
//

import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    var restaurant: Restaurant

    // Flag to control actions (like button taps)
    @State private var shouldAllowActions: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1) Display image
                if let imageUrl = restaurant.imageUrls.first {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 200)
                    }
                } else {
                    Image(systemName: "fork.knife.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .foregroundColor(.gray)
                }

                // 2) Restaurant name
                Text(restaurant.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                // 3) Rating
                if let rating = restaurant.rating {
                    HStack {
                        Text(languageManager.translate("Rating:"))
                            .font(.headline)
                        Text("\(rating, specifier: "%.1f") ★")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }
                } else {
                    Text(languageManager.translate("Rating not available"))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // 4) Address
                if let streetNumber = restaurant.streetNumber,
                   let street = restaurant.street {
                    Text("\(languageManager.translate("Address:")) \(streetNumber) \(street)")
                        .font(.body)
                        .padding(.vertical, 5)
                } else {
                    Text(languageManager.translate("Address not available"))
                        .font(.body)
                        .foregroundColor(.gray)
                }

                // 5) “Destination” button - opens maps
                if let _ = restaurant.latitude, let _ = restaurant.longitude {
                    Button {
                        if shouldAllowActions {
                            openPreferredMap(for: restaurant)
                        }
                    } label: {
                        Text(languageManager.translate("Destination"))
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }

                // 6) Website link
                if let url = restaurant.url {
                    if shouldAllowActions {
                        Link(languageManager.translate("Visit Website"), destination: url)
                            .font(.body)
                            .foregroundColor(.blue)
                    } else {
                        Text(languageManager.translate("Action not allowed"))
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(languageManager.translate("Website not available"))
                        .font(.body)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(languageManager.translate("Restaurant Details"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Enable actions
            shouldAllowActions = true
        }
    }

    // MARK: - Open Maps
    private func openPreferredMap(for restaurant: Restaurant) {
        guard let lat = restaurant.latitude, let lon = restaurant.longitude else { return }

        // 1) Read the user's map choice from UserDefaults
        //    (Default to Apple Maps if no preference saved)
        let userPreference = UserDefaults.standard.string(forKey: "MapChoice") ?? MapChoice.appleMaps.rawValue

        // 2) If user selected Google Maps
        if userPreference == MapChoice.googleMaps.rawValue {
            // First try x-callback (allows returning to the app if user picks "Back to fied")
            let xCallbackURLString = "comgooglemaps-x-callback://?daddr=\(lat),\(lon)&directionsmode=driving&x-success=fied://"
            if let xCallbackURL = URL(string: xCallbackURLString),
               UIApplication.shared.canOpenURL(xCallbackURL) {
                UIApplication.shared.open(xCallbackURL)
                return
            }

            // Fallback to plain comgooglemaps://
            let googleMapsString = "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving"
            if let googleMapsURL = URL(string: googleMapsString),
               UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL)
                return
            }
        }

        // 3) If we reach here, fallback to Apple Maps
        let coords = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coords)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Preview
struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRestaurant = Restaurant(
            id: UUID().uuidString,
            name: "Sample Restaurant",
            rating: 4.5,
            imageUrls: [URL(string: "https://via.placeholder.com/150")!],
            street: "123 Main St",
            streetNumber: "456",
            latitude: 45.5017,
            longitude: -73.5673,
            phoneNumber: "123-456-7890",
            url: URL(string: "https://www.samplerestaurant.com"),
            reviews: []
        )
        return NavigationView {
            RestaurantDetailView(restaurant: sampleRestaurant)
                .environmentObject(LanguageManager()) 
        }
    }
}

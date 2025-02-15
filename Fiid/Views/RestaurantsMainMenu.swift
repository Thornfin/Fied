//
//  RestaurantsMainMenu.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-28.
//

// RestaurantsMainMenu.swift


import SwiftUI
import CoreLocation

struct RestaurantsMainMenu: View {
    var restaurant: Restaurant
    var isSelected: Bool
    var onSelect: () -> Void
    var userLocation: CLLocationCoordinate2D? // Added user's current location

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.7, blendDuration: 0.1)) {
                onSelect()
                scale = 1.1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.0
                }
            }
        }) {
            VStack(spacing: 5) {
                // Image
                if let imageUrl = restaurant.imageUrls.first {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .onAppear {
                                    print("Attempting to load image from URL: \(imageUrl) for restaurant: \(restaurant.name)")
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onAppear {
                                    print("Successfully loaded image for \(restaurant.name)")
                                }
                        case .failure(let error):
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onAppear {
                                    print("Failed to load image for \(restaurant.name): \(error.localizedDescription)")
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Placeholder image
                    Image(systemName: "fork.knife.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear {
                            print("No image URL available for \(restaurant.name)")
                        }
                }

                // Restaurant name, rating, and distance
                VStack(spacing: 2) {
                    Text(restaurant.name)
                        .foregroundColor(.black)
                        .bold()
                        .font(.system(size: 16))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let rating = restaurant.rating {
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", rating))
                                .foregroundColor(.black)
                                .bold()
                                .font(.system(size: 14))
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.small)
                        }
                    }

                    if let userLocation = userLocation, let restaurantLocation = restaurant.coordinate {
                        let distance = calculateDistance(from: userLocation, to: restaurantLocation)
                        Text(distance)
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 5)
            }
            .frame(width: 125, height: 220)
            .padding(.vertical, 5)
            .background(isSelected ? Color.green : Color.white)
            .cornerRadius(10.0)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.red, lineWidth: 3) // Red border
//            )
            .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
        
    }

    // Function to calculate distance
    func calculateDistance(from userLocation: CLLocationCoordinate2D, to restaurantLocation: CLLocationCoordinate2D) -> String {
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantLoc = CLLocation(latitude: restaurantLocation.latitude, longitude: restaurantLocation.longitude)
        let distanceInMeters = userLoc.distance(from: restaurantLoc)
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInMeters / 1000)
        }
    }
}

struct RestaurantsMainMenu_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantsMainMenu(
            restaurant: Restaurant(
                id: UUID().uuidString,
                name: "Boulangerie de Damascus",
                rating: 4.7,
                imageUrls: [URL(string: "https://via.placeholder.com/150")!],
                street: "Laurentide",
                streetNumber: "1609",
                latitude: 45.5017,
                longitude: -73.5673,
                phoneNumber: nil,
                url: nil,
                distance: nil,
                reviews: []
            ),
            isSelected: false,
            onSelect: {},
            userLocation: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)
        )
        .previewLayout(.sizeThatFits)
    }
}

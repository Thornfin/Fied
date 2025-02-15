//
//  RestaurantCardView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-19.
//

import SwiftUI
import CoreLocation

struct RestaurantCardView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var restaurant: Restaurant
    var namespace: Namespace.ID
    var userLocation: CLLocationCoordinate2D?

    @State private var showDetail = false
    @State private var isProcessingDetail = false

    var body: some View {
        ZStack {
            mainView
                .matchedGeometryEffect(id: restaurant.id, in: namespace)
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                RestaurantDetailView(restaurant: restaurant)
                    .environmentObject(languageManager)
                    .onAppear {
                        print("Detail view presented for: \(restaurant.name)")
                    }
            }
        }
    }

    // MARK: - Main Card View
    private var mainView: some View {
        Rectangle()
            .frame(width: 350, height: 250)
            .foregroundStyle(Color("DarkGreen"))
            .cornerRadius(30.0)
            .overlay(
                VStack(alignment: .leading, spacing: 8) {
                    // 1) Image
                    if let imageUrl = restaurant.imageUrls.first {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .cornerRadius(10)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(height: 120)
                        }
                    } else {
                        Image(systemName: "fork.knife.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .clipped()
                    }

                    // 2) Name
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    // 3) Rating
                    if let rating = restaurant.rating {
                        Text("\(languageManager.translate("Rating:")) \(rating, specifier: "%.1f") ★")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    // 4) “More” (Detail) button
                    HStack {
                        Spacer()
                        Button {
                            triggerDetailView()
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            )
            .shadow(radius: 5)
    }

    // MARK: - Trigger Detail Sheet
    private func triggerDetailView() {
        guard !isProcessingDetail else {
            print("Detail view already in progress for: \(restaurant.name)")
            return
        }
        
        print("Triggering detail view for: \(restaurant.name)")
        isProcessingDetail = true
        showDetail = true

        // Reset the flag after a short delay to allow repeated triggers
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessingDetail = false
            print("Reset isProcessingDetail for: \(restaurant.name)")
        }
    }
}

// MARK: - Preview
struct RestaurantCardView_Previews: PreviewProvider {
    @Namespace static var animationNamespace

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
            phoneNumber: nil,
            url: nil,
            reviews: []
        )

        RestaurantCardView(
            restaurant: sampleRestaurant,
            namespace: animationNamespace,
            userLocation: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)
        )
        .environmentObject(LanguageManager())
        .previewLayout(.sizeThatFits)
    }
}

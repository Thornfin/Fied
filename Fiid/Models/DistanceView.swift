//
//  DistanceView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-20.
//

import SwiftUI
import CoreLocation
import MapKit

// MARK: - DistanceView
/// A simple view that displays the distance from the user's current location
/// to a given `Restaurant`.
struct DistanceView: View {
    /// The `LocationManager` is an ObservableObject that provides the current user location
    /// via CoreLocation APIs. (Elsewhere, you might define a class called `LocationManager` that
    /// publishes `@Published var location: CLLocation?`.)
    @ObservedObject var locationManager: LocationManager

    /// The restaurant for which we want to show the distance.
    var restaurant: Restaurant

    var body: some View {
        VStack {
            // Check if we have both a user location and a valid restaurant coordinate.
            if let userLocation = locationManager.location,
               let restaurantCoordinate = restaurant.coordinate {
                // Calculate the distance using CoreLocation.
                let distance = calculateDistance(
                    from: userLocation,
                    to: CLLocation(latitude: restaurantCoordinate.latitude,
                                  longitude: restaurantCoordinate.longitude)
                )
                // Display the formatted distance string.
                Text("Distance: \(formattedDistance(distance))")
                    .font(.headline)
            } else {
                // If user location or restaurant coordinate is not available,
                // show a placeholder.
                Text("Calculating distance...")
                    .font(.subheadline)
            }
        }
    }

    /// A helper function to calculate the distance in meters between two `CLLocation`s.
    /// - Parameters:
    ///   - from: The user's current `CLLocation`.
    ///   - to: A `CLLocation` created from the restaurant’s latitude/longitude.
    /// - Returns: The distance in meters.
    func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to)
    }

    /// Formats the raw distance (in meters) into a user-friendly string.
    /// For instance, "350 m" or "2.4 km".
    /// - Parameter distance: A `CLLocationDistance` value in meters.
    /// - Returns: A string representing the distance in abbreviated units.
    func formattedDistance(_ distance: CLLocationDistance) -> String {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        return distanceFormatter.string(fromDistance: distance)
    }
}


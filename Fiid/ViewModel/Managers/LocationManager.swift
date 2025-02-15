//
//  LocationManager.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import Foundation
import CoreLocation
import Combine

/// A LocationManager that uses CoreLocation for tracking user’s location,
/// caching it to prevent unnecessary updates within 5 km, and optionally
/// reverse-geocoding the user’s current location to get a `placeName`.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Properties

    /// The underlying CoreLocation manager instance.
    private let manager = CLLocationManager()
    
    /// The user’s current location (or last known location). Published to notify SwiftUI views.
    @Published var location: CLLocation?

    /// The current authorization status (e.g., `.denied`, `.authorizedWhenInUse`).
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// A human-readable place name for the current location (e.g., city or neighborhood).
    @Published var placeName: String = "Unknown"

    /// A cached location for distance comparison. If the user remains within `cacheRadius`,
    /// we won’t update the location or trigger reverse geocoding again.
    private var cachedLocation: CLLocation?

    /// The maximum distance (in meters) before forcing a location update
    /// even if the user remains within the same general area.
    /// Changed from 1 km to 5 km.
    private let cacheRadius: CLLocationDistance = 5000 // 5 km

    /// A reference to the pending geocoding task, so we can cancel if needed.
    private var geocodingTask: DispatchWorkItem?

    // MARK: - Initialization

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Requests permission and starts location updates if necessary.
    /// If there is no cached location, we immediately start updating.
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        if cachedLocation == nil {
            manager.startUpdatingLocation()
        }
    }

    /// Stops active location updates if we decide no further updates are needed.
    func stopLocationUpdates() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Obtain the most recent location.
        guard let newLocation = locations.first else { return }

        // If we have a cached location, compare the distance to decide if we need an update.
        if let cached = cachedLocation {
            let distance = cached.distance(from: newLocation)
            if distance > cacheRadius {
                // User moved more than 5 km from the cached location; update everything.
                cachedLocation = newLocation
                DispatchQueue.main.async {
                    self.location = newLocation
                    self.updatePlaceName(from: newLocation)
                }
            } else {
                // The user remains within 5 km of the cached location—no need to update or geocode.
                print("User within 5km of cached location, no need to update.")
                stopLocationUpdates()
            }
        } else {
            // No cached location yet, so cache the first location and geocode it.
            cachedLocation = newLocation
            DispatchQueue.main.async {
                self.location = newLocation
                self.updatePlaceName(from: newLocation)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    // MARK: - Reverse Geocoding

    /// Performs reverse geocoding on the user’s current location to get a place name (city, etc.).
    /// Uses a small delay (0.5s) to throttle multiple updates if the user is moving quickly.
    func updatePlaceName(from location: CLLocation?) {
        guard let location = location else { return }

        // Cancel any existing reverse geocode in progress.
        geocodingTask?.cancel()

        // Create a new dispatch work item to perform geocoding.
        geocodingTask = DispatchWorkItem {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.placeName = "Unknown"
                    }
                    return
                }

                // Grab the first placemark and pick a suitable name (locality or name).
                if let placemark = placemarks?.first {
                    let name = placemark.locality ?? placemark.name ?? "Unknown"
                    DispatchQueue.main.async {
                        self.placeName = name
                    }
                } else {
                    DispatchQueue.main.async {
                        self.placeName = "Unknown"
                    }
                }
            }
        }

        // Execute the geocoding task after a short delay (0.5s).
        // If the user moves again within 0.5s, we cancel and re-schedule.
        if let task = geocodingTask {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: task)
        }
    }
}

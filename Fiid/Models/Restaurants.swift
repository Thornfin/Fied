//
//  Restaurants.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-30.
//
// Restaurant.swift

import Foundation
import CoreLocation

// MARK: - Restaurant Model
/// Represents a restaurant with optional geographic data and other properties.
/// The `coordinate` computed property makes it easy to get a `CLLocationCoordinate2D`
/// for distance calculations.
struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double?
    let imageUrls: [URL]
    let street: String?
    let streetNumber: String?
    let latitude: Double?
    let longitude: Double?
    let phoneNumber: String?
    let url: URL?
    let distance: Double?
    let reviews: [RestaurantReview]?

    // Additional optional fields for filters
    let isHalal: Bool?
    let isVegan: Bool?
    let isVegetarian: Bool?
    let isHealthy: Bool?
    let isFancy: Bool?
    let isAesthetic: Bool?
    let servesCoffee: Bool?
    let isCheap: Bool?
    let servesPastry: Bool?

    // A simpler initializer for newly discovered restaurants
    init(
        id: String,
        name: String,
        rating: Double? = nil,
        imageUrls: [URL] = [],
        street: String? = nil,
        streetNumber: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        phoneNumber: String? = nil,
        url: URL? = nil,
        distance: Double? = nil,
        reviews: [RestaurantReview]? = nil,
        isHalal: Bool? = false,
        isVegan: Bool? = false,
        isVegetarian: Bool? = false,
        isHealthy: Bool? = false,
        isFancy: Bool? = false,
        isAesthetic: Bool? = false,
        servesCoffee: Bool? = false,
        isCheap: Bool? = false,
        servesPastry: Bool? = false
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.imageUrls = imageUrls
        self.street = street
        self.streetNumber = streetNumber
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.url = url
        self.distance = distance
        self.reviews = reviews
        self.isHalal = isHalal
        self.isVegan = isVegan
        self.isVegetarian = isVegetarian
        self.isHealthy = isHealthy
        self.isFancy = isFancy
        self.isAesthetic = isAesthetic
        self.servesCoffee = servesCoffee
        self.isCheap = isCheap
        self.servesPastry = servesPastry
    }

    // MARK: - Computed Property for Coordinates
    /// A helper property that transforms `latitude` and `longitude`
    /// into a `CLLocationCoordinate2D`, if they exist.
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}



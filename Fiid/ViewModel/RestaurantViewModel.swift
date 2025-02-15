//
//  RestaurantViewModel.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-20.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []

    private let googleAPIKey = "" 
    private let cacheExpiryDays = 30

    // Cache keys
    private let placeIDCacheKey = "PlaceIDCache"
    private let placeDetailsCacheKey = "PlaceDetailsCache"

    // Throttle/Guard
    private var lastSearchLocation: CLLocationCoordinate2D?
    private var lastSearchTimestamp: Date?

    private struct CachedPlaceIDEntry: Codable {
        let placeID: String
        var lastUsed: Date
    }

    private struct CachedDetailEntry: Codable {
        let restaurant: Restaurant
        var lastUsed: Date
    }

    private var placeIDCache: [String: CachedPlaceIDEntry] = [:]
    private var placeDetailsCache: [String: CachedDetailEntry] = [:]

    init() {
        loadCaches()
        pruneOldEntries()
    }

    // MARK: - MAIN: Search Nearby Restaurants
    func searchNearbyRestaurants(location: CLLocationCoordinate2D, resultLimit: Int = 24) {
        // 1) Throttle repeated calls: if you pressed language in ProfileView,
        //    we do NOT want to keep searching again within the same few seconds or same location.
        if shouldSkipSearch(newLocation: location) {
            print("Skipping repeated or too-frequent search near: \(location.latitude), \(location.longitude)")
            return
        }

        print("Searching restaurants near: \(location.latitude), \(location.longitude)")
        lastSearchLocation = location
        lastSearchTimestamp = Date()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Restaurant"

        // 10 km bounding region
        let regionRadius: CLLocationDistance = 10000
        request.region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionRadius * 2,
            longitudinalMeters: regionRadius * 2
        )

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            if let error = error {
                print("Error searching for restaurants: \(error)")
                return
            }
            guard let mapItems = response?.mapItems else {
                print("No restaurants found.")
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let allRestaurants = mapItems.compactMap { item -> Restaurant? in
                    guard let coordinate = item.placemark.location?.coordinate else { return nil }
                    let distance = userLocation.distance(from: item.placemark.location!)

                    return Restaurant(
                        id: UUID().uuidString,
                        name: item.name ?? "Unknown",
                        rating: nil,
                        imageUrls: [],
                        street: item.placemark.thoroughfare,
                        streetNumber: item.placemark.subThoroughfare,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        phoneNumber: item.phoneNumber,
                        url: item.url,
                        distance: distance
                    )
                }

                // Sort by distance
                let sortedRestaurants = allRestaurants.sorted {
                    ($0.distance ?? .greatestFiniteMagnitude) < ($1.distance ?? .greatestFiniteMagnitude)
                }

                // Limit
                let limitedRestaurants = Array(sortedRestaurants.prefix(resultLimit))

                DispatchQueue.main.async {
                    print("Fetched \(limitedRestaurants.count) restaurants.")
                    self?.restaurants = limitedRestaurants
                    // Attempt to enrich each
                    limitedRestaurants.forEach { restaurant in
                        self?.enrichRestaurant(restaurant)
                    }
                }
            }
        }
    }

    // MARK: - HELPER: Should we skip searching?
    private func shouldSkipSearch(newLocation: CLLocationCoordinate2D) -> Bool {
        // If last search was < 5 seconds ago, skip
        if let timestamp = lastSearchTimestamp, Date().timeIntervalSince(timestamp) < 5 {
            return true
        }

        // If we haven't searched before, don't skip
        guard let lastLoc = lastSearchLocation else { return false }

        // If the new location is within 300 meters of the old, skip
        let oldCL = CLLocation(latitude: lastLoc.latitude, longitude: lastLoc.longitude)
        let newCL = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        let dist = oldCL.distance(from: newCL)
        if dist < 300 {
            return true
        }

        return false
    }

    // MARK: - ENRICH: fetchPlaceID + fetchPlaceDetails
    func enrichRestaurant(_ restaurant: Restaurant) {
        fetchPlaceID(for: restaurant) { [weak self] placeID in
            guard let self = self, let placeID = placeID else { return }
            self.fetchPlaceDetails(placeID: placeID) { detailedRestaurant in
                guard let detailedRestaurant = detailedRestaurant else { return }
                DispatchQueue.main.async {
                    if let index = self.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
                        self.restaurants[index] = detailedRestaurant
                    }
                }
            }
        }
    }

    private func fetchPlaceID(for restaurant: Restaurant, completion: @escaping (String?) -> Void) {
        pruneOldEntries()

        // 1) Check cache
        if var cachedEntry = placeIDCache[restaurant.id] {
            cachedEntry.lastUsed = Date()
            placeIDCache[restaurant.id] = cachedEntry
            completion(cachedEntry.placeID)
            return
        }

        // 2) Construct URL
        guard let lat = restaurant.latitude, let lon = restaurant.longitude else {
            completion(nil)
            return
        }
        let encodedName = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let locationBias = "\(lat),\(lon)"
        let urlString = """
        https://maps.googleapis.com/maps/api/place/findplacefromtext/json?\
        input=\(encodedName)&\
        inputtype=textquery&\
        fields=place_id&\
        locationbias=point:\(locationBias)&\
        key=\(googleAPIKey)
        """

        guard let url = URL(string: urlString) else {
            print("Invalid URL for fetchPlaceID")
            completion(nil)
            return
        }

        // 3) Fetch Data
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error fetching Place ID: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data returned from fetchPlaceID")
                completion(nil)
                return
            }

            // Debug if needed:
            // print("FindPlaceResponse JSON:\n\(String(data: data, encoding: .utf8) ?? "")")

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FindPlaceResponse.self, from: data)
                let placeID = response.candidates.first?.place_id

                if let placeID = placeID {
                    print("Fetched Place ID: \(placeID) for restaurant: \(restaurant.name)")
                    var newEntry = CachedPlaceIDEntry(placeID: placeID, lastUsed: Date())
                    self?.placeIDCache[restaurant.id] = newEntry
                    self?.saveCaches()
                } else {
                    print("No Place ID found for restaurant: \(restaurant.name)")
                }
                completion(placeID)
            } catch {
                print("Error parsing JSON in fetchPlaceID: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    private func fetchPlaceDetails(placeID: String, completion: @escaping (Restaurant?) -> Void) {
        pruneOldEntries()

        // 1) Check cache
        if var cached = placeDetailsCache[placeID] {
            cached.lastUsed = Date()
            placeDetailsCache[placeID] = cached
            completion(cached.restaurant)
            return
        }

        // 2) Construct URL
        let fields = "name,rating,formatted_phone_number,website,photo,geometry,formatted_address,review,types,price_level"
        let urlString = """
        https://maps.googleapis.com/maps/api/place/details/json?\
        place_id=\(placeID)&\
        fields=\(fields)&\
        key=\(googleAPIKey)
        """

        guard let url = URL(string: urlString) else {
            print("Invalid URL for fetchPlaceDetails")
            completion(nil)
            return
        }

        // 3) Fetch Data
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error fetching place details: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data returned from place details request.")
                completion(nil)
                return
            }

            // Debug if needed:
            // print("PlaceDetailsResponse JSON:\n\(String(data: data, encoding: .utf8) ?? "")")

            do {
                let decoder = JSONDecoder()
                let detailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)

                guard detailsResponse.status == "OK",
                      let result = detailsResponse.result else {
                    print("Error in Place Details API response: \(detailsResponse.status)")
                    completion(nil)
                    return
                }

                let imageUrls = result.photos?.prefix(1).compactMap {
                    self?.photoURL(from: $0.photo_reference)
                } ?? []

                let reviews = result.reviews?.map {
                    RestaurantReview(author_name: $0.author_name,
                                     rating: $0.rating,
                                     text: $0.text,
                                     time: $0.time ?? 0)
                } ?? []

                let restaurant = Restaurant(
                    id: placeID,
                    name: result.name ?? "Unknown",
                    rating: result.rating,
                    imageUrls: imageUrls,
                    street: result.formatted_address,
                    latitude: result.geometry?.location.lat,
                    longitude: result.geometry?.location.lng,
                    reviews: reviews
                )

                // Cache
                let newDetail = CachedDetailEntry(restaurant: restaurant, lastUsed: Date())
                self?.placeDetailsCache[placeID] = newDetail
                self?.saveCaches()

                completion(restaurant)
            } catch {
                print("Error parsing JSON in fetchPlaceDetails: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    private func photoURL(from photoReference: String) -> URL? {
        let urlString = """
        https://maps.googleapis.com/maps/api/place/photo?\
        maxwidth=400&\
        photoreference=\(photoReference)&\
        key=\(googleAPIKey)
        """
        return URL(string: urlString)
    }

    // MARK: - Cache Management
    private func pruneOldEntries() {
        let now = Date()

        placeIDCache = placeIDCache.filter { _, entry in
            let daysDiff = Calendar.current.dateComponents([.day], from: entry.lastUsed, to: now).day ?? 0
            return daysDiff < cacheExpiryDays
        }

        placeDetailsCache = placeDetailsCache.filter { _, entry in
            let daysDiff = Calendar.current.dateComponents([.day], from: entry.lastUsed, to: now).day ?? 0
            return daysDiff < cacheExpiryDays
        }

        saveCaches()
    }

    private func saveCaches() {
        do {
            let encodedIDs = try JSONEncoder().encode(placeIDCache)
            UserDefaults.standard.set(encodedIDs, forKey: placeIDCacheKey)

            let encodedDetails = try JSONEncoder().encode(placeDetailsCache)
            UserDefaults.standard.set(encodedDetails, forKey: placeDetailsCacheKey)
        } catch {
            print("Error encoding caches: \(error)")
        }
    }

    private func loadCaches() {
        let decoder = JSONDecoder()

        if let data = UserDefaults.standard.data(forKey: placeIDCacheKey) {
            do {
                let decoded = try decoder.decode([String: CachedPlaceIDEntry].self, from: data)
                placeIDCache = decoded
            } catch {
                print("Error decoding placeIDCache: \(error)")
                placeIDCache = [:]
            }
        }

        if let data = UserDefaults.standard.data(forKey: placeDetailsCacheKey) {
            do {
                let decoded = try decoder.decode([String: CachedDetailEntry].self, from: data)
                placeDetailsCache = decoded
            } catch {
                print("Error decoding placeDetailsCache: \(error)")
                placeDetailsCache = [:]
            }
        }
    }
}

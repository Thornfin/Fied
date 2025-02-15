//
//  Model.swift
//  Fiid
//
//  Created by ilyass Serghini on 2025-01-08.
//

import Foundation
import CoreLocation

// MARK: - Top-Level FindPlaceResponse

struct FindPlaceResponse: Codable {
    let candidates: [Candidate]
    let status: String
    let error_message: String?

    // Defensive decoding example: in case `candidates` can be a single object or empty string
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // If decoding fails, fallback to empty
        self.candidates = (try? container.decode([Candidate].self, forKey: .candidates)) ?? []
        self.status = (try? container.decode(String.self, forKey: .status)) ?? "UNKNOWN"
        self.error_message = try? container.decode(String.self, forKey: .error_message)
    }
}

struct Candidate: Codable {
    let place_id: String
}

// MARK: - Top-Level PlaceDetailsResponse

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetailsResult?
    let status: String
    let error_message: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // If decoding fails, fallback to nil
        self.result = try? container.decode(PlaceDetailsResult.self, forKey: .result)
        self.status = (try? container.decode(String.self, forKey: .status)) ?? "UNKNOWN"
        self.error_message = try? container.decode(String.self, forKey: .error_message)
    }
}

struct PlaceDetailsResult: Codable {
    let name: String?
    let rating: Double?
    let formatted_phone_number: String?
    let website: String?
    let photos: [Photo]?
    let geometry: Geometry?
    let formatted_address: String?
    let reviews: [GooglePlaceReview]?
    let types: [String]?
    let price_level: Int?

    // Defensive decoding to handle empty strings or missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try? container.decode(String.self, forKey: .name)
        self.rating = try? container.decode(Double.self, forKey: .rating)
        self.formatted_phone_number = try? container.decode(String.self, forKey: .formatted_phone_number)
        self.website = try? container.decode(String.self, forKey: .website)

        // Photos can be an array or sometimes an empty string. If decode fails, fallback to nil.
        self.photos = try? container.decode([Photo].self, forKey: .photos)

        self.geometry = try? container.decode(Geometry.self, forKey: .geometry)
        self.formatted_address = try? container.decode(String.self, forKey: .formatted_address)

        // Reviews can be `[GooglePlaceReview]` or might be missing. If decode fails, fallback to nil.
        self.reviews = try? container.decode([GooglePlaceReview].self, forKey: .reviews)

        // Types might be `[String]` or empty string. If decode fails, fallback to nil.
        self.types = try? container.decode([String].self, forKey: .types)

        self.price_level = try? container.decode(Int.self, forKey: .price_level)
    }
}

struct Photo: Codable {
    let photo_reference: String
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - GooglePlaceReview with Defensive Decoding

struct GooglePlaceReview: Codable {
    let author_name: String
    let rating: Double
    let text: String
    let time: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.author_name = (try? container.decode(String.self, forKey: .author_name)) ?? "Unknown"
        self.rating = (try? container.decode(Double.self, forKey: .rating)) ?? 0
        self.text = (try? container.decode(String.self, forKey: .text)) ?? ""

        // 'time' might be an Int or a String or missing
        if let stringTime = try? container.decode(String.self, forKey: .time),
           let converted = Int(stringTime) {
            self.time = converted
        } else {
            self.time = try? container.decode(Int.self, forKey: .time)
        }
    }
}

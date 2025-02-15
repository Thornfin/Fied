//
//  RestaurantReview.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-11-19.
//

import Foundation

struct RestaurantReview: Codable, Identifiable, Equatable, Hashable {
    var id: String {
        return author_name + "\(time)"
    }
    let author_name: String
    let rating: Double
    let text: String
    let time: Int
}

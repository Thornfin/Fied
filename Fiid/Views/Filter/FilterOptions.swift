//
//  FilterOptions.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-12-24.
//

import SwiftUI

/// Represents each type of filter the user can select (e.g., Halal, Vegan, etc.).
enum FilterOption: CaseIterable, Identifiable {

    case halal
    case vegan
    case vegetarian
    case distance
    case healthy
    case reviews
    case fancy
    case estetic
    case coffee
    case cheap
    case pastry
    case clear

    // MARK: - Identifiable
    public var id: String { self.title }

    // MARK: - SF Symbol Name
    var symbolName: String {
        switch self {
        case .halal:       return "moon.fill"
        case .vegan:       return "leaf.fill"
        case .vegetarian:  return "camera.macro"
        case .distance:    return "mappin"
        case .healthy:     return "heart.fill"
        case .reviews:     return "star.fill"
        case .fancy:       return "sparkle"
        case .estetic:     return "sparkles"
        case .coffee:      return "cup.and.saucer.fill"
        case .cheap:       return "dollarsign"
        case .pastry:      return "birthday.cake.fill"
        case .clear:       return "xmark"
        }
    }

    // MARK: - Title
    var title: String {
        switch self {
        case .halal:       return "Halal"
        case .vegan:       return "Vegan"
        case .vegetarian:  return "Vegetarian"
        case .distance:    return "Distance"
        case .healthy:     return "Healthy"
        case .reviews:     return "Reviews"
        case .fancy:       return "Fancy"
        case .estetic:     return "Estetic"
        case .coffee:      return "Coffee"
        case .cheap:       return "Cheap"
        case .pastry:      return "Pastry"
        case .clear:       return "Clear"
        }
    }

    // MARK: - Filtering Predicate
    func predicate(for restaurant: Restaurant) -> Bool {
        switch self {
        case .halal:
            
            return restaurant.isHalal ?? false

        case .vegan:
            return restaurant.isVegan ?? false

        case .vegetarian:
            return restaurant.isVegetarian ?? false

        case .distance:
            
            return true

        case .healthy:
            return restaurant.isHealthy ?? false

        case .reviews:
            
            return true

        case .fancy:
            return restaurant.isFancy ?? false

        case .estetic:

            return restaurant.isAesthetic ?? false

        case .coffee:
            return restaurant.servesCoffee ?? false

        case .cheap:
            return restaurant.isCheap ?? false

        case .pastry:
            return restaurant.servesPastry ?? false

        case .clear:
            // "Clear" means no filter, so always return true.
            return true
        }
    }
}

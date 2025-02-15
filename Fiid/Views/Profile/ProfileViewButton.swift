//
//  ProfileViewButton.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-16.
//

import SwiftUI
import Foundation

enum Allergy: String, CaseIterable, Identifiable {
    case peanuts    = "Peanuts"
    case shellfish  = "Shellfish"
    case kiwi       = "Kiwi"

    var id: String { rawValue }
}

enum AccountType: String, CaseIterable, Identifiable {
    case personal         = "Personal"
    case restaurantOwner  = "Restaurant Owner"

    var id: String { rawValue }
}

enum MapChoice: String, CaseIterable, Identifiable {
    case appleMaps  = "Apple Maps"
    case googleMaps = "Google Maps"

    var id: String { rawValue }
}

enum ProfileOption: CaseIterable, Identifiable {
    case language
//    case allergies
//    case accountType
    case reportBug
    case mapPreference

    var id: String {
        switch self {
        case .language:     return "language"
//        case .allergies:    return "allergies"
//        case .accountType:  return "accountType"
        case .reportBug:    return "reportBug"
        case .mapPreference:return "mapPreference"
        }
    }

    func title(for language: Language) -> String {
        switch self {
        case .language:
            return language == .english ? "Language" : "Langue"
//        case .allergies:
//            return language == .english ? "Allergies" : "Allergies"
//        case .accountType:
//            return language == .english ? "Type of Account" : "Type de Compte"
        case .reportBug:
            return language == .english ? "Report Bug" : "Signaler un Bug"
        case .mapPreference:
            return language == .english ? "Preferred Map" : "Carte Préférée"
        }
    }

    var iconName: String {
        switch self {
        case .language:
            return "globe"
//        case .allergies:
//            return "exclamationmark.triangle"
//        case .accountType:
//            return "person.crop.circle"
        case .reportBug:
            return "ladybug"
        case .mapPreference:
            return "map"
        }
    }
}

// A button to display each ProfileOption item
struct ProfileOptionButton: View {
    let option: ProfileOption
    let action: () -> Void
    let language: Language

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: option.iconName)
                    .foregroundColor(.darkGreen)
                Text(option.title(for: language))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

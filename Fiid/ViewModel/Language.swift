//
//  Language.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-12-24.
//

import Foundation

/// The list of supported languages in the app.
enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case french  = "Français"

    var id: String { rawValue }
}


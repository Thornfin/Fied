//
//  LanguageManager.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-12-24.
//

import SwiftUI
import Combine
/// This file contains translations.
/// This ObservableObject holds the user-selected language and your translation data.
/// The entire app observes `selectedLanguage` automatically.
class LanguageManager: ObservableObject {
    @Published var selectedLanguage: Language = .english {
        didSet {
            guard oldValue != selectedLanguage else { return }
            print("Language changed to: \(selectedLanguage)")
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "AppLanguage")
        }
    }

    // Can expand this dictionary with any keys the app needs.
    private let translations: [Language: [String: String]] = [
        .english: [
            // FilterOption keys
            "Halal": "Halal",
            "Vegan": "Vegan",
            "Vegetarian": "Vegetarian",
            "Distance": "Distance",
            "Healthy": "Healthy",
            "Reviews": "Reviews",
            "Fancy": "Fancy",
            "Estetic": "Esthetic",
            "Coffee": "Coffee",
            "Cheap": "Cheap",
            "Pastry": "Pastry",
            "Clear": "Clear",

            // Profile strings
            "Welcome !": "Welcome !",
            "Select Language": "Select Language",
            "Select Allergy": "Select Allergy",
            "Select Account Type": "Select Account Type",

            
            // Random button
            "Feeling Hungry?": "Feeling Hungry?",
            "Let us pick something for you!": "Let us pick something for you!",
            "Surprise Me!": "Surprise Me!",
            "Reroll": "Reroll",
            "Restaurants": "Restaurants",
            
            // Forms
            "Select an Issue": "Select an Issue",
            "Request Restaurant Account": "Request Restaurant Account",
            "Report a Bug": "Report a Bug",
            "Other": "Other",
            "Contact Us": "Contact Us",
            "Name": "Name",
            "Email": "Email",
            "Reason for Contact": "Reason for Contact",
            "Submit": "Submit",
            "Cancel": "Cancel",
            "Describe the bug here...": "Describe the bug here...",
            "characters": "characters",
            "Restaurant Verification": "Restaurant Verification",
            "Restaurant Name": "Restaurant Name",
            "Restaurant Address": "Restaurant Address",
            "Contact Number": "Contact Number",
            "Upload Proof of Ownership": "Upload Proof of Ownership",
            "Tap to select image": "Tap to select image",
            "Select Photo": "Select Photo",
            "Camera": "Camera",
            "Photo Library": "Photo Library",
            "Error": "Error",
            
            // Location bar
            "Fetching location...": "Fetching location...",
            "Search for restaurants...": "Search for restaurants...",
            
            // Restaurant Details / Card
            "Restaurant Details": "Restaurant Details",
            "Rating:": "Rating:",
            "Address:": "Address:",
            "Visit Website": "Visit Website",
            "Details": "Details",
            "Distance:": "Distance:"
        ],
        .french: [
            // FilterOption keys
            "Halal": "Halal",
            "Vegan": "Végétalien",
            "Vegetarian": "Végétarien",
            "Distance": "Distance",
            "Healthy": "Sain",
            "Reviews": "Avis",
            "Fancy": "Raffiné",
            "Estetic": "Esthétique",
            "Coffee": "Café",
            "Cheap": "Bon marché",
            "Pastry": "Pâtisserie",
            "Clear": "Effacer",

            // Profile strings
            "Welcome !": "Bienvenue !",
            "Select Language": "Choisir la Langue",
            "Select Allergy": "Choisir une Allergie",
            "Select Account Type": "Choisir le Type de Compte",
            
            // Random button
            "Feeling Hungry?": "Vous avez faim ?",
            "Let us pick something for you!": "Laissez-nous choisir pour vous !",
            "Surprise Me!": "Surprenez-moi !",
            "Reroll": "Relancer",
            "Restaurants": "Restaurants",
            
            // Forms
            "Select an Issue": "Sélectionnez un problème",
            "Request Restaurant Account": "Demander un compte de restaurant",
            "Report a Bug": "Signaler un bug",
            "Other": "Autre",
            "Contact Us": "Nous contacter",
            "Name": "Nom",
            "Email": "E-mail",
            "Reason for Contact": "Raison du contact",
            "Submit": "Soumettre",
            "Cancel": "Annuler",
            "Describe the bug here...": "Décrivez le bug ici...",
            "characters": "caractères",
            "Restaurant Verification": "Vérification du restaurant",
            "Restaurant Name": "Nom du restaurant",
            "Restaurant Address": "Adresse du restaurant",
            "Contact Number": "Numéro de contact",
            "Upload Proof of Ownership": "Télécharger une preuve de propriété",
            "Tap to select image": "Appuyez pour sélectionner une image",
            "Select Photo": "Choisir une photo",
            "Camera": "Appareil photo",
            "Photo Library": "Bibliothèque de photos",
            "Error": "Erreur",
            
            // Location bar
            "Fetching location...": "Récupération de l'emplacement...",
            "Search for restaurants...": "Rechercher des restaurants...",
            
            // Restaurant Details / Card
            "Restaurant Details": "Détails du Restaurant",
            "Rating:": "Note :",
            "Rating not available": "Note non disponible",
            "Address:": "Adresse :",
            "Address not available": "Adresse non disponible",
            "Visit Website": "Visiter le Site",
            "Website not available": "Site non disponible",
            "Destination": "Destination",
            "Action not allowed": "Action non autorisée",
            "Details": "Détails",
            "Distance:": "Distance :"
        ]
    ]

    /// Use this function to get a localized version of any key.
    func translate(_ key: String) -> String {
        translations[selectedLanguage]?[key] ?? key
    }

    func loadSavedLanguage() {
        if let raw = UserDefaults.standard.string(forKey: "AppLanguage"),
           let lang = Language(rawValue: raw) {
            selectedLanguage = lang
        }
    }
}

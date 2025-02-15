//
//  FiidApp.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-28.
//

import SwiftUI
import FirebaseCore
//
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FiidApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        CacheUtility.clearCacheIfNeeded()
    }
    
    // Initialize LanguageManager in a closure so it’s properly created before the view
    @StateObject private var languageManager: LanguageManager = {
        let manager = LanguageManager()
        manager.loadSavedLanguage()  
        return manager
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
        }
    }
}

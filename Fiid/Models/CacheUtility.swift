//
//  CacheUtility.swift
//  Fiid
//
//  Created by ilyass Serghini on 2025-01-08.
//

import Foundation

struct CacheUtility {

    static let placeIDCacheKey = "PlaceIDCache"
    static let placeDetailsCacheKey = "PlaceDetailsCache"

    // Force clear: Call this once if you suspect old data is corrupted
    static func clearAllCacheData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: placeIDCacheKey)
        defaults.removeObject(forKey: placeDetailsCacheKey)
        defaults.synchronize()
        print("All restaurant caches cleared.")
    }

    // Version-based clearing
    static func clearCacheIfNeeded() {
        let currentCacheVersion = 2
        let storedVersionKey = "CacheVersion"

        let defaults = UserDefaults.standard
        let oldVersion = defaults.integer(forKey: storedVersionKey)
        if oldVersion < currentCacheVersion {
            // Clear the old caches if the version changed
            clearAllCacheData()
            defaults.set(currentCacheVersion, forKey: storedVersionKey)
        }
    }
}

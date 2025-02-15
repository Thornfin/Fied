//
//  SearchViewModel.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-20.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - SearchViewModel

class SearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var searchCompleter: MKLocalSearchCompleter
    private var searchCancellable: AnyCancellable?
    
    override init() {
        self.searchCompleter = MKLocalSearchCompleter()
        super.init()
        self.searchCompleter.delegate = self
        self.searchCompleter.resultTypes = .address
    }
    
    func updateSearchResults(for query: String) {
        searchCompleter.queryFragment = query
    }
    
    func getCoordinate(from completion: MKLocalSearchCompletion, completionHandler: @escaping (CLLocationCoordinate2D?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                completionHandler(coordinate)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error updating search completer results: \(error.localizedDescription)")
    }
}

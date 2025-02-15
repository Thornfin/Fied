//
//  MainView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-20.
//

import SwiftUI

struct MainView: View {
    @State private var isShowingDetail: Bool = false
    @State private var isShowingSearch: Bool = false
    @State private var searchText: String = ""
    @State private var selectedFilters: Set<FilterOption> = [.halal]
    @State private var selectedRestaurant: Restaurant? = nil

    @ObservedObject var restaurantViewModel = RestaurantViewModel()

    var body: some View {
        NavigationView {
            VStack {
                LocationBarView(
                    restaurantViewModel: restaurantViewModel,
                    isShowingDetail: $isShowingDetail,
                    isShowingSearch: $isShowingSearch,
                    searchText: $searchText,
                    selectedFilters: $selectedFilters,
                    selectedRestaurant: $selectedRestaurant
                )
                Spacer()
                BottomBarNavigationView(
                    isShowingSearch: $isShowingSearch,
                    selectedRestaurant: $selectedRestaurant,
                    restaurantViewModel: restaurantViewModel
                )
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - PreviewProvider

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

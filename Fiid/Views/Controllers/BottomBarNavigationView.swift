//
//  BottomBarNavigationView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import SwiftUI

struct BottomBarNavigationView: View {
    @Binding var isShowingSearch: Bool
    @Binding var selectedRestaurant: Restaurant?
    @ObservedObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 80) {
            NavigationLink(destination: RandomRestaurantView(selectedRestaurant: $selectedRestaurant, restaurants: restaurantViewModel.restaurants)) {
                Image(systemName: "dice.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            Button(action: {
                if selectedRestaurant != nil {
                    selectedRestaurant = nil
                }

                withAnimation(.easeInOut(duration: 0.15)) {
                    isShowingSearch.toggle()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color("DarkGreen"))
        .ignoresSafeArea(edges: .bottom) 
    }
}

// MARK: - PreviewProvider

struct BottomBarNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RestaurantViewModel()
        BottomBarNavigationView(
            isShowingSearch: .constant(false),
            selectedRestaurant: .constant(nil),
            restaurantViewModel: viewModel
        )
    }
}

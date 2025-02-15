//
//  FilterView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import SwiftUI

/// A scrollable grid of filter buttons.
struct FilterView: View {
    @EnvironmentObject var languageManager: LanguageManager

    @Binding var isShowingDetail: Bool
    @Binding var selectedFilters: Set<FilterOption>

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()

                // Display rows of FilterButtons (4 across by default)
                ForEach(FilterOption.allCases.chunked(into: 4), id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(row) { option in
                            FilterButton(symbol: option, selectedFilters: $selectedFilters)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.white
                .ignoresSafeArea()
        )
    }
}

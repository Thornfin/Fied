//
//  FilterButton.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import SwiftUI

struct FilterButton: View {
    @EnvironmentObject var languageManager: LanguageManager

    var symbol: FilterOption
    @Binding var selectedFilters: Set<FilterOption>

    @State private var scale: CGFloat = 1.0

    var isSelected: Bool {
        selectedFilters.contains(symbol)
    }

    var iconSize: CGFloat = 30
    var showText: Bool = true
    var showBackgroundCircle: Bool = true

    /// The color used for the selected state (default to .green).
    var selectedColor: Color? = nil
    /// The color used for the unselected state (default to .gray).
    var unselectedColor: Color? = nil

    var body: some View {
        VStack {
            Button(action: toggleFilter) {
                Image(systemName: symbol.symbolName)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.white)
                    .padding(showBackgroundCircle ? 20 : 0)
                    .background(
                        Circle()
                            .fill(
                                isSelected
                                    ? (selectedColor ?? .green)
                                    : (unselectedColor ?? .gray)
                            )
                            .scaleEffect(scale)
                            .opacity(symbol == .clear ? 0.7 : 1.0)
                    )
            }
            .animation(.spring(), value: isSelected)

            if showText {
                Text(languageManager.translate(symbol.title))
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.top, 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }

    private func toggleFilter() {
        if symbol == .clear {
            withAnimation(.spring()) {
                selectedFilters.removeAll()
            }
            return
        }
        withAnimation(.spring()) {
            if isSelected {
                selectedFilters.remove(symbol)
            } else {
                selectedFilters.insert(symbol)
            }
        }
        // Simple bounce effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                scale = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.0
                }
            }
        }
    }
}

//
//  ButtonNavigation.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-09-29.
//

import SwiftUI

struct ButtonNavigation: View {
    var symbol: SFSymbol
    
    var body: some View {
        
        ZStack{
            Button(action: {}, label: {
                Text(Image(systemName: symbol.rawValue))
            })
            .foregroundColor(.white)
            
        }
    }
}

enum SFSymbol: String, CaseIterable {
    case personCropCircle = "person.crop.circle"
    case magnifyingglass = "magnifyingglass"
    case dice = "dice.fill"
}

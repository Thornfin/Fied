//
//  FiedView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-21.
//

import SwiftUI

struct FiedView: View {
    var body: some View {
        ZStack {
            Color("DarkGreen")
                .ignoresSafeArea()
            Image("isolatedLogo")
                .resizable()
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    FiedView()
}

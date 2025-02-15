//
//  WaveCirlcesView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-19.
//

import SwiftUI

struct WaveCirclesView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 15, height: 15)
                    .offset(y: animate ? -10 : 10)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear {
            self.animate = true
        }
    }
}

#Preview {
    WaveCirclesView()
}


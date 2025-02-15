//
//  AsyncButton.swift
//  Fiid
//
//  Created by on 2025-01-02.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    @State private var isPerformingTask = false

    var body: some View {
        Button {
            guard !isPerformingTask else { return }
            isPerformingTask = true
            Task {
                await action()
                isPerformingTask = false
            }
        } label: {
            ZStack {
                label()
                    .opacity(isPerformingTask ? 0 : 1)
                if isPerformingTask {
                    ProgressView()
                }
            }
        }
        .disabled(isPerformingTask)
    }
}

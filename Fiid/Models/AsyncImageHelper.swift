//
//  AsyncImageHelper.swift
//  Fiid
//
//  Created by ilyass Serghini on 2025-01-08.
//

import SwiftUI

struct SafeAsyncImage<Placeholder: View>: View {
    @State private var loadedImage: Image? = nil
    let url: URL?
    let placeholder: Placeholder

    init(url: URL?, @ViewBuilder placeholder: () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder()
    }

    var body: some View {
        ZStack {
            if let loadedImage = loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholder
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        guard let url = url else { return }
        // Example concurrency fix: dispatch in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

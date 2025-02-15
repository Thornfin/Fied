//
//  KeyboardAwareModifier.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-17.
//

import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                guard let userInfo = notification.userInfo,
                      let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return endFrame.minY >= UIScreen.main.bounds.height ? 0 : endFrame.height
            }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
    }

    deinit {
        cancellable?.cancel()
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @StateObject private var keyboardObserver = KeyboardObserver()

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardObserver.keyboardHeight)
    }
}

extension View {
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}

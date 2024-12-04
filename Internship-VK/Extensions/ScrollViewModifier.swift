//
//  ScrollViewModifier.swift
//  Internship-VK
//
//  Created by Artemy Fillman on 03/12/2024.
//

import SwiftUI

// Ключ для отслеживания прокрутки
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Модификатор для выполнения действия при достижении конца списка
extension View {
    func onScrollReached(perform action: @escaping () async -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollViewOffsetPreferenceKey.self, value: proxy.frame(in: .global).maxY)
            }
        )
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { offset in
            if offset < 100 { // Когда прокрутка достигает конца
                Task {
                    await action()
                }
            }
        }
    }
}


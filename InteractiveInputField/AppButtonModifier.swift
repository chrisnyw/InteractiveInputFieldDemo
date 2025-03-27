//
//  AppButtonModifier.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-31.
//

import SwiftUI

// view modifier
struct AppButtom: ViewModifier {
    func body(content: Content) -> some View {
        content
            .symbolRenderingMode(.palette)
            .foregroundStyle(.gray)
    }
}

// view extension for better modifier access
extension View {
    func applyAppButtonStyle() -> some View {
        modifier(AppButtom())
    }
}

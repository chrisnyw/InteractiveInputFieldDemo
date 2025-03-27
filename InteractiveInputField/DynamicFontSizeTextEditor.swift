//
//  DynamicFontSizeTextEditor.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-31.
//

import SwiftUI
import Combine

struct DynamicFontSizeTextEditor: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    var isFocusedAction: ((Bool) -> Void)?
    
    @State private var fontSize: CGFloat = Constants.Font.maximumMessageFontSize
    @State private var editorHeight: CGFloat = 80 // Fixed height
    @State private var textEditorSize: CGSize = .zero
    
    private let minFontSize: CGFloat = Constants.Font.minimumMessageFontSize
    private let maxFontSize: CGFloat = Constants.Font.maximumMessageFontSize
    private let textPublisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: fontSize))
            .frame(height: editorHeight)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .overlay(alignment: .topLeading, content: {
                if text.isEmpty {
                    Text(Constants.Text.inputTextFieldPlaceholder)
                        .foregroundStyle(.gray)
                        .allowsHitTesting(false)
                        .padding(.leading, 4)
                        .padding(.top, 8)
                }
            })
            .onChange(of: text) {
                textPublisher.send()
            }
            .onReceive(
                textPublisher.debounce(
                    for: .milliseconds(500),
                    scheduler: DispatchQueue.main
                )
            ) {
                adjustFontSize()
            }
            .onChange(of: isFocused) {
                isFocusedAction?(isFocused)
            }
            .focused($isFocused)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: {
                textEditorSize = $0
            }
    }
    
    private func adjustFontSize() {
        let constraintSize = CGSize(width: textEditorSize.width, height: .infinity)
        
        let calculatedHeight = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: fontSize)],
            context: nil
        ).height
        
        let heightRatio = calculatedHeight / editorHeight
        
        if heightRatio >= 2/3 {
            fontSize = max(fontSize - 2, minFontSize)
        } else if heightRatio <= 1/2 && fontSize < maxFontSize {
            fontSize = min(fontSize + 2, maxFontSize)
        }
    }
}

struct DynamicFontSizeTextEditor_Previews: PreviewProvider {
    @State static var message: String = ""
    @FocusState static var isFocused: Bool
    
    static var previews: some View {
        DynamicFontSizeTextEditor(text: $message, isFocused: $isFocused)
    }
}

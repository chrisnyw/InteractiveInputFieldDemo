//
//  DynamicFontSizeTextEditor.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-31.
//

import SwiftUI
import Combine

struct DynamicFontSizeTextEditor: View {
    @State private var text: String
    @Binding private var debounceText: String
    
    @FocusState.Binding private var isFocused: Bool
    private var isFocusedAction: ((Bool) -> Void)?
    
    @State private var fontSize: CGFloat = Constants.Font.maximumMessageFontSize
    @State private var editorHeight: CGFloat = 80 // Fixed height
    @State private var textEditorSize: CGSize = .zero
    
    private let minFontSize: CGFloat = Constants.Font.minimumMessageFontSize
    private let maxFontSize: CGFloat = Constants.Font.maximumMessageFontSize
    private let textPublisher = PassthroughSubject<String, Never>()
    
    init(text: Binding<String>, isFocused: FocusState<Bool>.Binding, isFocusedAction: ((Bool) -> Void)? = nil) {
        _text = State(initialValue: text.wrappedValue)
        _debounceText = text
        _isFocused = isFocused
        self.isFocusedAction = isFocusedAction
    }
    
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
                textPublisher.send(text)
            }
            .onReceive(
                textPublisher
                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                    .scan((oldText: "", isAddingText: false), { lastTuple, newText in
                        let isAddingText = newText.count > lastTuple.oldText.count
                        return (oldText: String(newText), isAddingText: isAddingText)
                    })
            ) { tuple in
                fontSize = adjustFontSize(updatedText: tuple.oldText, isAddingText: tuple.isAddingText)
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
    
    private func adjustFontSize(updatedText: String, isAddingText: Bool) -> CGFloat {
        var oldFontSize = fontSize
        var newFontSize = self.calculateExpectedFontSize(currentFontSize: oldFontSize, updatedText: updatedText, isAddingText: isAddingText)
        
        // adjust the font size until it fit the space
        while newFontSize != oldFontSize {
            oldFontSize = newFontSize
            newFontSize = self.calculateExpectedFontSize(currentFontSize: oldFontSize, updatedText: updatedText, isAddingText: isAddingText)
        }
        
        return newFontSize
    }
    
    private func calculateExpectedFontSize(currentFontSize: CGFloat, updatedText: String, isAddingText: Bool) -> CGFloat {
        let textEditorPadding: CGFloat =  16
        let constraintSize = CGSize(width: textEditorSize.width - textEditorPadding, height: .infinity)
        
        let calculatedHeight = updatedText.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: currentFontSize)],
            context: nil
        ).height
        
        let heightRatio = calculatedHeight / editorHeight
        
        var tempFontSize = currentFontSize
        
        if heightRatio >= 2/3, isAddingText {
            tempFontSize = max(currentFontSize - 2, minFontSize)
            print("😢 decrease fontSize to \(tempFontSize)")
        } else if heightRatio <= 1/2 && fontSize < maxFontSize && !isAddingText {
            tempFontSize = min(currentFontSize + 2, maxFontSize)
            print("😢 increase fontSize to \(tempFontSize)")
        }
        
        print("textEditorSize.width: \(textEditorSize.width), calculatedHeight: \(calculatedHeight), heightRatio: \(heightRatio), fontSize: \(tempFontSize), isAddingText: \(isAddingText)")
        return tempFontSize
    }
}

#Preview {
    @Previewable @State var message: String = ""
    @FocusState var isFocused: Bool
    
    DynamicFontSizeTextEditor(text: $message, isFocused: $isFocused)
}

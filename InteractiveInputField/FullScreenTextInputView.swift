//
//  FullScreenTextInputView.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-28.
//

import SwiftUI

struct FullScreenTextInputView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var message: String
    var switchToPhotoSelectionView: (() -> Void)?
    var sendMessageAction: (() -> Void)?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    TextField(Constants.Text.inputTextFieldPlaceholder, text: $message, axis: .vertical)
                        .padding()
                        .font(.system(size: Constants.Font.maximumMessageFontSize))
                        .frame(maxHeight: .infinity, alignment: .top)
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: Constants.Icon.collapse)
                            .applyAppButtonStyle()
                    }
                }
                BottomSheetButtonsBar(photoPickerAction: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        switchToPhotoSelectionView?()
                    }
                }, sendAction: {
                    sendMessageAction?()
                })
            }
            .padding()
        }
            
    }
    
}

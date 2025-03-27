//
//  BottomSheetButtonsBar.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-31.
//

import SwiftUI

struct BottomSheetButtonsBar: View {
    var photoPickerAction: (() -> Void)?
    var sendAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Button {
                photoPickerAction?()
            } label: {
                Image(systemName: Constants.Icon.photoLibrary)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .applyAppButtonStyle()
            }
            Spacer()
            Button {
                sendAction?()
            } label: {
                Image(systemName: Constants.Icon.sendMessage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .applyAppButtonStyle()
            }
        }
    }
}

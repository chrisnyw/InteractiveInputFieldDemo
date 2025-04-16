//
//  InteractiveInputTextModel.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-04-11.
//

import SwiftUI
import PhotosUI

@Observable class InteractiveInputTextViewModel {
    enum BottomMode {
        case keyboard
        case photo
        case none
    }
    
    var message: String = ""
    var showFullScreenTextInputView = false

    // photo
    var showingPhotoPickerSheet = false
    var selectedPhotoItem: PhotosPickerItem? = nil
    var selectedImage: Image? = nil
    
    var bottomMode: BottomMode = .none
    
}

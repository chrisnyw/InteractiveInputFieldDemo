//
//  BottomPhotoSelectionViewModel.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-04-15.
//

import SwiftUI
import PhotosUI

@MainActor @Observable class BottomPhotoSelectionViewModel {
    
    var photoAuthStatus: PHAuthorizationStatus = .notDetermined
    private var photoLibraryService: PhotoLibraryService? = nil
    
    func setup(photoLibraryService: PhotoLibraryService) {
        self.photoLibraryService = photoLibraryService
    }
    
    func requestPermission() {
        photoLibraryService?.requestAuthorization { [weak self] status in
            self?.photoAuthStatus = status
        }
    }
    
}

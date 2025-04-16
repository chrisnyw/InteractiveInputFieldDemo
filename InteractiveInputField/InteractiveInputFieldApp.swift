//
//  InteractiveInputFieldApp.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-27.
//

import SwiftUI

@main
struct InteractiveInputFieldApp: App {
    private let photoLibraryService: PhotoLibraryService = RealPhotoLibraryService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environment(\.photoLibraryService, photoLibraryService)
            
        }
    }
}


extension EnvironmentValues {
    @Entry var photoLibraryService: PhotoLibraryService = MockPhotoLibraryService()
}

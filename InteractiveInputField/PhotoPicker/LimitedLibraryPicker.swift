//
//  LimitedLibraryPicker.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-04-15.
//

import SwiftUI
import Photos

struct LimitedLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        if isPresented {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
            }
        }
    }
}

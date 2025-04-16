//
//  BottomPhotoSelectionSheetView.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-04-14.
//

import SwiftUI
import Photos

struct BottomPhotoSelectionSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.photoLibraryService) var photoLibraryService: PhotoLibraryService
    
    @Binding private var selectedImage: Image?
    @State private var tempSelectedImage: Image?
    
    @State private var viewModel: BottomPhotoSelectionViewModel = BottomPhotoSelectionViewModel()
    @State private var showManagePhotoOptions: Bool = false
    @State private var showLimitedPicker: Bool = false
    
    init(selectedImage: Binding<Image?>) {
        _selectedImage = selectedImage
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                authorizedStatus()

                BottomPhotoSelectionView(selectedImage: $tempSelectedImage)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            // Left button
                            Button {
                                print("dismiss photo picker")
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                        
                        // Right Button
                        if let rightButton = rightButton {
                            ToolbarItem(placement: .topBarTrailing) {
                                rightButton
                            }
                        }
                    }
            }
        }
        .background(
            LimitedLibraryPicker(isPresented: $showLimitedPicker)
        )
        .onFirstAppear {
            viewModel.setup(photoLibraryService: photoLibraryService)
            viewModel.requestPermission()
        }
        .onChange(of: tempSelectedImage) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedImage = tempSelectedImage
                }
            }
        }
        .alert("Select more photos or go to Settings to allow access to all photos.", isPresented: $showManagePhotoOptions) {
            Button("Select more photos") {
                showLimitedPicker = true
            }
            Button("Allow access to all photos") {
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            Button("Cancel", role: .cancel) { }
         }
    }
    
    private var rightButton: Button<Text>? {
        switch viewModel.photoAuthStatus {
        case .notDetermined,
                .authorized:
            return nil
        case .restricted:
            return nil
        case .denied:
            return nil
        case .limited:
            return Button {
                print("manage")
                showManagePhotoOptions = true
            } label: {
                Text("Manage")
            }
        @unknown default:
            return nil
        }
    }
    
    @ViewBuilder private func authorizedStatus() -> some View {
        switch viewModel.photoAuthStatus {
        case .notDetermined,
                .authorized:
            EmptyView()
        case .restricted:
            Text("Photo access restricted")
        case .denied:
            Text("Photo access denied")
        case .limited:
            Text("Limited access to photos")
        @unknown default:
            EmptyView()
        }
    }

    
}

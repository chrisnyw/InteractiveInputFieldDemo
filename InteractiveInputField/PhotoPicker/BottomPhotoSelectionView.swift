//
//  BottomPhotoSelectionView.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-28.
//

import SwiftUI
import PhotosUI

struct BottomPhotoSelectionView: View {
    private struct Constants {
        static let GridSpacing: CGFloat = 2
    }
    
    @Environment(\.photoLibraryService) var photoLibraryService: PhotoLibraryService
    
    @Binding var selectedImage: Image?
    
    @State private var images: [UIImage] = []
    
    var body: some View {
        showPhotoList
    }

    private var showPhotoList: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Constants.GridSpacing), count: 3),
            spacing: Constants.GridSpacing
        ) {
            ForEach(images, id: \ .self) { image in
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedImage = Image(uiImage: image)
                    }
            }
        }
        .onFirstAppear {
            photoLibraryService.fetchPhotoAssets()
        }
        .onReceive(photoLibraryService.fetchedImagesPublisher) { fetchedImages in
            images = fetchedImages
        }
    }

}

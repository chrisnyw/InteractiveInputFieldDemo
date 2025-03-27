//
//  BottomPhotoSelectionView.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-28.
//

import SwiftUI
import PhotosUI

struct BottomPhotoSelectionView: View {
    @Binding var selectedImage: Image?
    
    @State private var images: [UIImage] = []

    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)) {
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
        }
        .onAppear(perform: loadImages)
    }
    
    private func loadImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 9
        let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.sortDescriptors = sortOrder
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHImageManager.default()
        fetchResult.enumerateObjects { asset, _, _ in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
    }
}

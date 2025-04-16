//
//  PhotoLibraryService.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-04-15.
//

import SwiftUI
import Photos
import Combine

protocol PhotoLibraryService {
    var fetchedImagesPublisher: AnyPublisher<[UIImage], Never> { get }
    
    func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void)
    func fetchPhotoAssets(completion: (([UIImage]) -> Void)?)
}

extension PhotoLibraryService {
    func fetchPhotoAssets(completion: (([UIImage]) -> Void)? = nil) {
        self.fetchPhotoAssets(completion: completion)
    }
}

class RealPhotoLibraryService: NSObject, PhotoLibraryService {
    
    private var fetchedImages = PassthroughSubject<[UIImage], Never>()
    var fetchedImagesPublisher: AnyPublisher<[UIImage], Never> {
        return fetchedImages.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(status)
        }
    }

    func fetchPhotoAssets(completion: (([UIImage]) -> Void)?) {
        var images: [UIImage] = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        let group = DispatchGroup()
        
        assets.enumerateObjects { asset, _, _ in
            group.enter()
            imageManager.requestImage(for: asset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFill,
                                      options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            completion?(images)
            self?.fetchedImages.send(images)
        }
    }
}

extension RealPhotoLibraryService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.fetchPhotoAssets(completion: { _ in })
    }
}


class MockPhotoLibraryService: PhotoLibraryService {
    private var fetchedImages = PassthroughSubject<[UIImage], Never>()
    var fetchedImagesPublisher: AnyPublisher<[UIImage], Never> {
        return self.fetchedImages.eraseToAnyPublisher()
    }
    
    func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {}
    func fetchPhotoAssets(completion: (([UIImage]) -> Void)?) {}
}

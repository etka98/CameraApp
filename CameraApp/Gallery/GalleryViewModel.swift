//
//  GalleryViewModel.swift
//  CameraApp
//
//  Created by Etka Uzun on 24.04.2024.
//

import Foundation

final class GalleryViewState {
    
    enum Change {
        
        case retrievedImageURLs
        case error(Error?)
    }
    
    var onChange: ((GalleryViewState.Change) -> Void)?
}

final class GalleryViewModel {
    
    /// Boolean value indicating whether currently in editing state.
    var isEditing = false
    
    /// Closure for given state.
    var stateChangeHandler: ((GalleryViewState.Change) -> Void)? {
        get { state.onChange }
        set { state.onChange = newValue }
    }
    
    private enum Constant {
        
        static let sizeUnits = ["KB", "MB", "GB", "TB"]
        static let sizeFormat = "%.2f %@"
        static let defaultUnit = "Byte"
        static let unitSize = 1000.0
    }
    
    private let state = GalleryViewState()
    
    /// Fetches images from local data storage.
    func loadImages() {
        StoredImageManager.shared.loadImages { error in
            if let error {
                state.onChange?(.error(error))
                return
            }
            
            state.onChange?(.retrievedImageURLs)
        }
    }
    
    /// Deletes image from local data storage.
    ///  - Parameters:
    ///     - index: Integer value indicating index of item.
    func deleteImage(at index: Int) {
        if let error = StoredImageManager.shared.deleteImage(at: index) {
            state.onChange?(.error(error))
        }
    }
    
    /// Calculates total size of the stored images.
    ///  - Returns: Formated file size.
    func calculateSizeOfFile() -> String {
        var totalFileSize = StoredImageManager.shared.calculateSizeOfFile()
        var sizeUnit = Constant.defaultUnit
        
        for unit in Constant.sizeUnits {
            guard totalFileSize > Constant.unitSize else {
                break
            }
            totalFileSize /= Constant.unitSize
            sizeUnit = unit
        }
        
        return String(format: Constant.sizeFormat, totalFileSize, sizeUnit)
    }
    
    /// Deletes all images from local data storage.
    func deleteAllImages() {
        if let error = StoredImageManager.shared.deleteAllImages() {
            state.onChange?(.error(error))
        }
    }
}

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
    
    /// List of urls of the stored image data.
    var imageURLs: [URL] = []
    
    /// Closure for given state.
    var stateChangeHandler: ((GalleryViewState.Change) -> Void)? {
        get { state.onChange }
        set { state.onChange = newValue }
    }
    
    private enum Constant {
        
        static let sizeUnits = ["KB", "MB", "GB", "TB"]
        static let sizeFormat = "%.2f %@"
        static let defaultUnit = "Byte"
    }
    
    private let state = GalleryViewState()
    
    /// Fetches images from local data storage.
    func loadImages() {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else {
            return
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil)
            imageURLs = fileURLs
            state.onChange?(.retrievedImageURLs)
        } catch {
            state.onChange?(.error(error))
        }
    }
    
    /// Deletes image from local data storage.
    ///  - Parameters:
    ///     - index: Integer value indicating index of item.
    func deleteImage(at index: Int) {
        let fileURL = imageURLs[index]
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                state.onChange?(.error(error))
            }
        }
    }
    
    /// Calculates total size of the stored images.
    ///  - Returns: Formated file size.
    func calculateSizeOfFile() -> String {
        var totalFileSize = 0.0
        var sizeUnit = Constant.defaultUnit
        for url in imageURLs {
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            if let attributes = attributes, 
                let fileSize = attributes[.size] as? NSNumber {
                totalFileSize += fileSize.doubleValue
            }
        }
        
        for unit in Constant.sizeUnits {
            guard totalFileSize > 1000.0 else {
                break
            }
            totalFileSize /= 1000.0
            sizeUnit = unit
        }
        
        return String(format: Constant.sizeFormat, totalFileSize, sizeUnit)
    }
}

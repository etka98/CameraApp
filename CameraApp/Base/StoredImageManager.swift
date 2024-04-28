//
//  StoredImageManager.swift
//  CameraApp
//
//  Created by Etka Uzun on 28.04.2024.
//

import Foundation

class StoredImageManager: NSObject {
    
    /// Shared instance of StoredImageManager.
    static let shared = StoredImageManager()
    
    /// List of urls of the stored image data.
    var imageURLs: [URL] = []
    
    private override init() {
        super.init()
    }
    
    /// Fetches images from local data storage.
    ///  - Parameter completion: The callback called after retrieval.
    func loadImages(completion: (Error?) -> Void) {
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
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    /// Deletes image from local data storage.
    ///  - Parameters:
    ///     - index: Integer value indicating index of item.
    ///  - Returns: Error caught during deletion. Returns nil if succesfull.
    func deleteImage(at index: Int) -> Error? {
        let fileURL = imageURLs[index]
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                return error
            }
        }
        
        return nil
    }
    
    /// Deletes all images from local data storage.
    ///  - Returns: Error caught during deletion. Returns nil if succesfull.
    @discardableResult
    func deleteAllImages() -> Error? {
        for fileUrl in imageURLs {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    try FileManager.default.removeItem(at: fileUrl)
                } catch {
                    return error
                }
            }
        }
        
        return nil
    }
    
    /// Calculates total size of the stored images.
    ///  - Returns: Double value of file size.
    func calculateSizeOfFile() -> Double {
        var totalFileSize = 0.0
        for url in imageURLs {
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            if let attributes = attributes,
                let fileSize = attributes[.size] as? NSNumber {
                totalFileSize += fileSize.doubleValue
            }
        }
        
        return totalFileSize
    }
    
    /// Saves given image data items to local data stroge.
    ///  - Parameters:
    ///     - imageDataList: List of image data to be stored.
    ///     - completion: The callback called after storing is complete.
    func saveImagesToLocalStroge(imageDataList: [Data?], completion: () -> Void) {
        for data in imageDataList {
            saveImageToLocalStorage(imageData: data)
        }
        completion()
    }
    
    @discardableResult
    private func saveImageToLocalStorage(imageData: Data?, fileExtension: String = "jpg") -> Bool {
        guard let imageData else {
            return false
        }
        
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let fileName = String(format: "%@.%@", UUID().uuidString, fileExtension)
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
}

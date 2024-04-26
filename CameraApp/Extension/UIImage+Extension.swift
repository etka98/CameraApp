//
//  UIImage+Extension.swift
//  CameraApp
//
//  Created by Etka Uzun on 24.04.2024.
//

import UIKit

extension UIImage {
    
    @discardableResult
    func saveToLocalStorage(compressionQuality: CGFloat = 1.0, fileExtension: String = "jpg") -> Bool {
        guard let imageData = jpegData(compressionQuality: compressionQuality) else {
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

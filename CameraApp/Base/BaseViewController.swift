//
//  BaseViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 27.04.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    // TODO: Localization
    private enum Localization {
        
        static let errorButtonTitle = "OK"
        static let errorTitle = "Error"
        static let unknownErrorMessage = "An unknown error occurred."
    }
    
    
    /// Creates alert with provided message.
    /// - Parameter message: Error message.
    func createAlertForError(message: String?) {
        let errorMessage = message != nil ? message : Localization.unknownErrorMessage
        let alert = UIAlertController(title: Localization.errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.errorButtonTitle, style: .cancel))
        
        present(alert, animated: true)
    }
}

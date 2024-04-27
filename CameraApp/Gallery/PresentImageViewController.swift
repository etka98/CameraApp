//
//  PresentImageViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 27.04.2024.
//

import UIKit

class PresentImageViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    /// Configures image.
    ///  - Parameter url: Image url.
    func configure(url: String) {
        imageView.image = UIImage(contentsOfFile: url)
    }
    
    private func setup() {
        view.addSubview(imageView)
        
        view.dock(subview: imageView)
    }
}

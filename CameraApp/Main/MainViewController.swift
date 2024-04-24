//
//  MainViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    private enum Constant {
        
        static let radius = 8.0
        static let borderWidth = 2.0
        static let imagePreviewWidthRatio = 0.7
    }
    
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        previewLayer.session = viewModel.captureSession
        
        return previewLayer
    }()
    
    private lazy var bottomView: CameraBottomView = {
        let bottomView = CameraBottomView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.delegate = self
        
        return bottomView
    }()
    
    private let lastImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constant.radius
        imageView.layer.borderWidth = Constant.borderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.isHidden = true
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setup()
    }
    
    deinit {
        viewModel.stopCamera()
    }
}

// MARK: CameraBottomDelegate

extension MainViewController: CameraBottomDelegate {
    
    func cameraBottomView(_ view: CameraBottomView, shouldStartRecording: Bool) {
        toggleLastImageView(isHidden: shouldStartRecording)
        if shouldStartRecording {
            viewModel.startCapture()
            return
        }
        
        viewModel.stopCapture()
        setLastCapturedImage()
    }
}

// MARK: Private - Setup

private extension MainViewController {
    
    private func setup() {
        viewModel.setupCamera()
        setupConstraint()
    }
    
    private func setupConstraint() {
        view.addSubview(bottomView)
        view.addSubview(lastImageView)
        
        view.center(subview: lastImageView)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            lastImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constant.imagePreviewWidthRatio)
        ])
    }
}

// MARK: Private - Helpers

private extension MainViewController {
    
    private func setLastCapturedImage() {
        guard let imageData = viewModel.lastImageData,
              let image = UIImage(data: imageData) else {
            return
        }
        lastImageView.image = image
        let ratio = (image.size.height) / (image.size.width)
        lastImageView.heightAnchor.constraint(equalTo: lastImageView.widthAnchor,
                                              multiplier: ratio).isActive = true
    }
    
    private func toggleLastImageView(isHidden: Bool) {
        lastImageView.isHidden = isHidden
    }
}

// MARK: Private - State Change Handler

private extension MainViewController {
    
    private func bindViewModel() {
        viewModel.stateChangeHandler = { [weak self] change in
            guard let self else {
                return
            }
            
            self.applyStateChange(change)
        }
    }
    
    private func applyStateChange(_ change: MainViewState.Change) {
        switch change {
        case .authorizedCamera:
            view.layer.insertSublayer(videoPreviewLayer, at: .zero)
        case .noCameraAccess:
            // TODO: Handle camera warning
            break
        case .imageCaptured(let imageData):
            guard let image = UIImage(data: imageData) else {
                return
            }
            image.saveToLocalStorageInBackground()
        case .error(let error):
            // TODO: Handle error
            break
        }
    }
}

//
//  MainViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        previewLayer.session = viewModel.captureSession
        
        return previewLayer
    }()
    
    private let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        setup()
    }
    
    private func setup() {
        viewModel.setupCamera()
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        
    }
    
    private func bindViewModel() {
        viewModel.stateChangeHandler = { [weak self] change in
            guard let self else { return }
            self.applyStateChange(change)
        }
    }
    
    deinit {
        viewModel.stopCamera()
    }
}

extension MainViewController {
    
    private func applyStateChange(_ change: MainViewState.Change) {
        switch change {
        case .isLoading(let isLoading):
            break
        case .authorizedCamera:
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.view.layer.insertSublayer(self.videoPreviewLayer, at: 0)
            }
        case .error:
            break
        }
    }
}


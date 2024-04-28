//
//  MainViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit
import AVFoundation

final class MainViewController: BaseViewController {
    
    private enum Constant {
        
        static let radius = 8.0
        static let borderWidth = 2.0
        static let imagePreviewWidthRatio = 0.7
    }
    
    // TODO: Localization
    private enum Localization {
        
        static let noCameraAccessMessage = "No Camera Access"
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
    
    private lazy var settingsViewController: SettingsViewController = {
        let viewController = SettingsViewController()
        viewController.delegate = self
        let activeFormat = viewModel.captureDevice?.activeFormat
        viewController.configure(
            minISO: activeFormat?.minISO,
            maxISO: activeFormat?.maxISO,
            minExposureDuration: activeFormat?.minExposureDuration.seconds,
            maxExposureDuration: activeFormat?.maxExposureDuration.seconds,
            currentISO: viewModel.captureDevice?.iso,
            currentExposureDuration: viewModel.captureDevice?.exposureDuration.seconds)
        
        return viewController
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
    
    func cameraBottomView(_ view: CameraBottomView, galleryButtonTapped: UIButton) {
        pauseSession()
        
        let galleryViewController = GalleryViewController()
        let galleryViewModel = GalleryViewModel()
        galleryViewModel.elapsedTime = viewModel.elapsedTime
        galleryViewController.viewModel = galleryViewModel
        galleryViewController.delegate = self
        navigationController?.pushViewController(galleryViewController, animated: true)
    }
    
    func cameraBottomView(_ view: CameraBottomView, settingsButtonTapped: UIButton) {
        guard let sheet = settingsViewController.sheetPresentationController else {
            return
        }
        
        sheet.detents = [.medium()]
        sheet.largestUndimmedDetentIdentifier = .medium
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        
        present(settingsViewController, animated: true, completion: nil)
    }
}

// MARK: SettingsViewDelegate

extension MainViewController: SettingsViewDelegate {
    
    func settingViewContoller(_ view: SettingsViewController, iso: Float, exposureDuration: Float) {
        viewModel.setIsoAndShutterSpeed(iso: iso, exposureDuration: exposureDuration)
    }
}

// MARK: GalleryViewControllerDelegate

extension MainViewController: GalleryViewControllerDelegate {
    
    func galleryViewController(_ viewController: GalleryViewController, didCompleteSession: Bool) {
        viewModel.elapsedTime = .zero
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
    
    private func pauseSession() {
        if bottomView.isRecording {
            viewModel.stopCapture()
        }
        bottomView.stopRecording()
        toggleLastImageView(isHidden: false)
        setLastCapturedImage()
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
            DispatchQueue.main.async { [weak  self] in
                guard let self else {
                    return
                }
                
                self.view.layer.insertSublayer(self.videoPreviewLayer, at: .zero)
            }
        case .noCameraAccess:
            createAlertForError(message: Localization.noCameraAccessMessage)
        case .imageCaptured(let imageData):
            DispatchQueue.global(qos: .background).async {
                guard let image = UIImage(data: imageData) else {
                    return
                }
                
                image.saveToLocalStorage()
            }
        case .error(let error):
            createAlertForError(message: error?.localizedDescription)
        }
    }
}

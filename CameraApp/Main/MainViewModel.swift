//
//  MainViewModel.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import Foundation
import AVFoundation

final class MainViewState {
    
    enum Change {
        case isLoading(Bool)
        case authorizedCamera
        case error
    }
    
    var onChange: ((MainViewState.Change) -> Void)?
}

class MainViewModel {
    
    var captureSession: AVCaptureSession?
    var stateChangeHandler: ((MainViewState.Change) -> Void)? {
        get { state.onChange }
        set { state.onChange = newValue }
    }
    
    private let state = MainViewState()
    private var cameraAuthorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func setupCamera() {
        switch cameraAuthorizationStatus {
        case .authorized:
            initializeSession()
            state.onChange?(.authorizedCamera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.initializeSession()
                    self.state.onChange?(.authorizedCamera)
                } else {
                    self.state.onChange?(.error)
                }
            }
        default:
            self.state.onChange?(.error)
        }
    }
    
    private func initializeSession() {
        captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        captureSession?.addInput(input)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
}

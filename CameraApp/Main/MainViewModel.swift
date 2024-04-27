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
        
        case authorizedCamera
        case noCameraAccess
        case imageCaptured(Data)
        case error(Error?)
    }
    
    var onChange: ((MainViewState.Change) -> Void)?
}

class MainViewModel: NSObject {
    
    private enum Constant {
        
        static let timeInterval = 0.2
        static let targetResolution: Int32 = 4000 * 3000
        static let preferredTimescale: CMTimeScale = 1000000
    }
    
    /// Data representing last captured image.
    var lastImageData: Data?
    
    /// Capture session.
    var captureSession: AVCaptureSession?
    
    /// Capture Device
    var captureDevice: AVCaptureDevice?
    
    /// Closure for given state
    var stateChangeHandler: ((MainViewState.Change) -> Void)? {
        get { state.onChange }
        set { state.onChange = newValue }
    }
    
    private let state = MainViewState()
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraTimer: Timer?
    private var cameraAuthorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Checks for camera authrization status.
    func setupCamera() {
        switch cameraAuthorizationStatus {
        case .authorized:
            initializeSession()
            state.onChange?(.authorizedCamera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else {
                    return
                }
                if granted {
                    self.initializeSession()
                    self.state.onChange?(.authorizedCamera)
                } else {
                    self.state.onChange?(.noCameraAccess)
                }
            }
        default:
            self.state.onChange?(.noCameraAccess)
        }
    }
    
    /// Stops capture session if necessary.
    func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    /// Starts timer to capture image periodically.
    func startCapture() {
        cameraTimer?.invalidate()
        cameraTimer = Timer.scheduledTimer(
            timeInterval: Constant.timeInterval,
            target: self,
            selector: #selector(captureImage),
            userInfo: nil,
            repeats: true)
    }
    
    /// Stops image capture timer.
    func stopCapture() {
        cameraTimer?.invalidate()
    }
    
    /// Sets iso and shutter speed.
    func setIsoAndShutterSpeed(iso: Float, exposureDuration: Float) {
        try? captureDevice?.lockForConfiguration()
        captureDevice?.setExposureModeCustom(
            duration: CMTime(seconds: Double(exposureDuration), preferredTimescale: Constant.preferredTimescale),
            iso: iso)
        captureDevice?.unlockForConfiguration()
    }
    
    @objc private func captureImage() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    private func initializeSession() {
        captureSession = AVCaptureSession()
        captureDevice = AVCaptureDevice.default(for: .video)
        photoOutput = AVCapturePhotoOutput()
        
        guard let captureDevice = captureDevice,
              let input = try? AVCaptureDeviceInput(device: captureDevice),
              let output = photoOutput else {
            return
        }
        
        setImageFormat()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
}

// MARK: AVCapturePhotoCaptureDelegate

extension MainViewModel: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Disable capturing sound.
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            state.onChange?(.error(error))
            return
        }
        
        lastImageData = imageData
        state.onChange?(.imageCaptured(imageData))
    }
}

// MARK: Private - Helpers

private extension MainViewModel {
    
    private func setImageFormat() {
        guard let camera = captureDevice,
              let selectedFormat = findClosestFormat(formats: camera.formats) else {
            return
        }
        
        do {
            try camera.lockForConfiguration()
            camera.activeFormat = selectedFormat
            camera.unlockForConfiguration()
        } catch {
            state.onChange?(.error(error))
        }
    }
    
    private func findClosestFormat(formats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        var selectedFormat: AVCaptureDevice.Format?
        var closestResolutionDifference = Int.max
        
        for format in formats {
            let formatDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let resolutionDifference = abs(formatDimensions.width * formatDimensions.height - Constant.targetResolution)
            
            if resolutionDifference < closestResolutionDifference {
                closestResolutionDifference = Int(resolutionDifference)
                selectedFormat = format
            }
        }
        
        return selectedFormat
    }
}

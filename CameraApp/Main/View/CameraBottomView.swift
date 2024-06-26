//
//  CameraBottomView.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit

protocol CameraBottomDelegate: AnyObject {

    /// Notfies whether recording should start.
    ///  - Parameters:
    ///     - view: Delegate owner.
    ///     - shouldStartRecording: Boolean value indicating whether recording should start.
    func cameraBottomView(_ view: CameraBottomView, shouldStartRecording: Bool)
    
    /// Notfies whether gallery button tapped.
    ///  - Parameters:
    ///     - view: Delegate owner.
    ///     - galleryButtonTapped: Tapped button.
    func cameraBottomView(_ view: CameraBottomView, galleryButtonTapped: UIButton)
    
    /// Notfies whether settings button tapped.
    ///  - Parameters:
    ///     - view: Delegate owner.
    ///     - settingsButtonTapped: Tapped button.
    func cameraBottomView(_ view: CameraBottomView, settingsButtonTapped: UIButton)
}

final class CameraBottomView: UIView {
    
    private enum Constant {
        
        static let recordButtonSize = CGSize(width: 100, height: 100)
        static let systemButtonSize = CGSize(width: 50, height: 50)
        static let cornerRadius = 50.0
        static let alpha = 0.5
        static let margin = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        static let settingsButtonImageName = "gearshape.fill"
        static let galleryButtonImageName = "tray.and.arrow.up.fill"
    }
    
    /// Delegate owner.
    weak var delegate: CameraBottomDelegate?
    
    /// Boolean value indicating whether is recording.
    var isRecording = false
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constant.margin
        
        return stackView
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: Constant.settingsButtonImageName), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = Constant.cornerRadius
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: Constant.galleryButtonImageName), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  Set nonrecording state.
    func stopRecording() {
        guard isRecording else{
            return
        }
        
        isRecording = false
        setRecordButtonBackgoundColor(isRecording: isRecording)
    }
}

// MARK: Private - Setup

private extension CameraBottomView {
    
    private func setup() {
        backgroundColor = .black
        alpha = Constant.alpha
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        addSubview(stackView)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(recordButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(galleryButton)
        
        dock(subview: stackView)
        settingsButton.set(width: Constant.systemButtonSize.width, height: Constant.systemButtonSize.height)
        recordButton.set(width: Constant.recordButtonSize.width, height: Constant.recordButtonSize.height)
        galleryButton.set(width: Constant.systemButtonSize.width, height: Constant.systemButtonSize.height)
    }
}

// MARK: Private - Actions

private extension CameraBottomView {
    
    @objc
    private func recordButtonTapped() {
        delegate?.cameraBottomView(self, shouldStartRecording: !isRecording)
        isRecording = !isRecording
        setRecordButtonBackgoundColor(isRecording: isRecording)
    }
    
    @objc
    private func settingsButtonTapped() {
        delegate?.cameraBottomView(self, settingsButtonTapped: settingsButton)
    }
    
    @objc
    private func galleryButtonTapped() {
        delegate?.cameraBottomView(self, galleryButtonTapped: galleryButton)
    }
}

// MARK: Private - Helpers

private extension CameraBottomView {
    
    private func setRecordButtonBackgoundColor(isRecording: Bool) {
        recordButton.backgroundColor = isRecording ? .red : .white
    }
}

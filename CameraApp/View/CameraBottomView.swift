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
}

class CameraBottomView: UIView {
    
    weak var delegate: CameraBottomDelegate?
    
    private enum Constant {
        
        static let recordButtonSize = CGSize(width: 100, height: 100)
        static let systemButtonSize = CGSize(width: 50, height: 50)
        static let cornerRadius = 50.0
        static let alpha = 0.5
        static let margin = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        static let settingsButtonImageName = "gearshape.fill"
        static let galleryButtonImageName = "tray.and.arrow.up.fill"
    }
    
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
    
    private var isRecording = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        // TODO: Notify delegate
    }
    
    @objc
    private func galleryButtonTapped() {
        // TODO: Notify delegate
    }
}

// MARK: Private - Helpers

private extension CameraBottomView {
    
    private func setRecordButtonBackgoundColor(isRecording: Bool) {
        recordButton.backgroundColor = isRecording ? .red : .white
    }
}

//
//  SettingsViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 26.04.2024.
//

import UIKit
import AVFoundation

protocol SettingsViewDelegate: AnyObject {

    /// Notifies when iso and exposure duration is confirmed.
    ///  - Parameters:
    ///     - view: Delegate owner.
    ///     - iso: Iso value.
    ///     - exposureDuration: Exposure duration value.
    func settingViewContoller(_ view: SettingsViewController, iso: Float, exposureDuration: Float)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewDelegate?
    
    private enum Constant {
        
        static let spacing = 24.0
        static let margins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        static let cornerRadius = 12.0
        static let buttonHeight = 50.0
    }
    
    private enum Localization {
        
        static let adjustButtonTitle = "Adjust"
        static let isoSliderTitle = "ISO"
        static let shutterSpeedTitle = "Shutter Speed"
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constant.spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constant.margins
        
        return stackView
    }()
    
    private let isoSlider: SliderWithLabelView = {
        let slider = SliderWithLabelView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    private let shutterSpeedSlider: SliderWithLabelView = {
        let slider = SliderWithLabelView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    private lazy var adjustButtonTitle: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Localization.adjustButtonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Constant.cornerRadius
        button.addTarget(self, action: #selector(adjustButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    /// Configures iso and exposure duration sliders' default value.
    ///  - Parameters:
    ///     - minISO: Minimum iso value.
    ///     - maxISO: Maximum iso value.
    ///     - minExposureDuration: Minimum exposure duration value.
    ///     - maxExposureDuration: Maximum exposure duration value.
    ///     - currentISO: Current iso value.
    ///     - currentExposureDuration: Current exposure duration value.
    func configure(
        minISO: Float?,
        maxISO: Float?,
        minExposureDuration: Double?,
        maxExposureDuration: Double?,
        currentISO: Float?,
        currentExposureDuration: Double?) {
        guard let minISO,
              let maxISO,
              let minExposureDuration,
              let maxExposureDuration,
              let currentISO,
              let currentExposureDuration else {
            return
        }
        
        isoSlider.configure(
            title: Localization.isoSliderTitle,
            minValue: minISO,
            maxValue: maxISO,
            currentValue: currentISO)
        shutterSpeedSlider.configure(
            title: Localization.shutterSpeedTitle,
            minValue: Float(minExposureDuration),
            maxValue: Float(maxExposureDuration),
            currentValue: Float(currentExposureDuration))
    }
    
    @objc
    private func adjustButtonTapped() {
        delegate?.settingViewContoller(
            self,
            iso: isoSlider.getSliderValue(),
            exposureDuration: shutterSpeedSlider.getSliderValue())
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Private - Setup

private extension SettingsViewController {
    
    private func setup() {
        view.backgroundColor = .white
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(isoSlider)
        stackView.addArrangedSubview(shutterSpeedSlider)
        stackView.addArrangedSubview(adjustButtonTitle)
        stackView.addArrangedSubview(UIView())
        
        adjustButtonTitle.set(width: nil, height: Constant.buttonHeight)
        view.dock(subview: stackView)
    }
}

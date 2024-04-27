//
//  SliderWithLabelView.swift
//  CameraApp
//
//  Created by Etka Uzun on 26.04.2024.
//

import UIKit

final class SliderWithLabelView: UIStackView {
    
    private enum Constant {
        
        static let spacing = 6.0
        static let format = "%.2f"
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.textAlignment = .left
        
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.textAlignment = .right
        
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .darkGray
        slider.thumbTintColor = .systemBlue
        slider.addTarget(self, action: #selector(sliderChangeHandler), for: .valueChanged)
        
        return slider
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures title and slider view.
    ///  - Parameters:
    ///     - title: Title value.
    ///     - minValue: Minimum value.
    ///     - maxValue: Maximum value.
    ///     - currentValue: Current value.
    func configure(title: String, minValue: Float, maxValue: Float, currentValue: Float) {
        titleLabel.text = title
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = currentValue
        valueLabel.text = String(format: Constant.format, currentValue)
    }
    
    /// Returns current slider value.
    ///  - Returns: Slider value.
    func getSliderValue() -> Float {
        return slider.value
    }
    
    private func setup() {
        axis = .vertical
        spacing = Constant.spacing
        
        addArrangedSubview(horizontalStackView)
        addArrangedSubview(slider)
    }
    
    @objc
    private func sliderChangeHandler(sender: UISlider) {
        valueLabel.text = String(format: Constant.format, sender.value)
    }
}

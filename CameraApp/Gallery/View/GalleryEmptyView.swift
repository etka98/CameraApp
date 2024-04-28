//
//  GalleryEmptyView.swift
//  CameraApp
//
//  Created by Etka Uzun on 28.04.2024.
//

import UIKit

class GalleryEmptyView: UIView {
    
    private enum Constant {
        
        static let systemImage = "magnifyingglass"
        static let spacing = 12.0
        static let margins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        static let imageSize = CGSize(width: 50, height: 50)
    }
    
    // TODO: Localization
    private enum Localization {
        
        static let emptyViewText = "No image data found"
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constant.systemImage)
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Localization.emptyViewText
        label.textAlignment = .center
        
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Constant.spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constant.margins
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .black
        
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        imageView.set(width: Constant.imageSize.width, height: Constant.imageSize.height)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
}


//
//  GalleryCollectionViewCell.swift
//  CameraApp
//
//  Created by Etka Uzun on 24.04.2024.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GalleryCollectionViewCell"
    
    private enum Constant {
        
        static let cornerRadius = 15.0
        static let borderWidth = 1.0
        static let alpha = 0.5
        static let labelSize = CGSize(width: 30, height: 30)
        static let labelMargin = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 4)
        static let checkIcon = "✓"
        static let emptyString = ""
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.textAlignment = .center
        label.layer.cornerRadius = Constant.cornerRadius
        label.layer.masksToBounds = true
        label.layer.borderWidth = Constant.borderWidth
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = .black.withAlphaComponent(Constant.alpha)
        
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            label.text = isSelected ? Constant.checkIcon : Constant.emptyString
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets image and editing state.
    ///  - Parameters:
    ///     - image: UIImage value indication displayed cell's image.
    ///     - isEditing: Boolean value indicating whether label should show.
    func configure(image: UIImage?, isEditing: Bool) {
        guard let image else {
            return
        }
        
        imageView.image = image
        label.isHidden = !isEditing
    }
    
    private func setup() {
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        contentView.dock(subview: imageView)
        
        label.set(width: Constant.labelSize.width, height: Constant.labelSize.height)
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(
                equalTo: label.trailingAnchor,
                constant: Constant.labelMargin.right),
            contentView.bottomAnchor.constraint(
                equalTo: label.bottomAnchor,
                constant: Constant.labelMargin.bottom)
        ])
    }
}

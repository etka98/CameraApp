//
//  UIView+Extension.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit

extension UIView {
    
    func dock(subview: UIView, margins: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.left),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margins.top),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: margins.right),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: margins.bottom)
        ])
    }
    
    func dock(superview: UILayoutGuide, margins: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins.left),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: margins.top),
            superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margins.right),
            superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom)
        ])
    }
    
    func center(subview: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            centerYAnchor.constraint(equalTo: subview.centerYAnchor)
        ])
    }
    
    func set(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

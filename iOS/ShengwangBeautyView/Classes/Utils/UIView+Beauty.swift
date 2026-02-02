//
//  UIView+Beauty.swift
//  BeautyView
//
//  Created by Auto on 2026/1/22.
//

import UIKit

internal extension UIView {
    /// Set rounding corners for the view
    /// - Parameters:
    ///   - corners: Corners to round
    ///   - radius: Corner radius
    func setRoundingCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    /// Set corner radius for the view
    /// - Parameter radius: Corner radius
    func cornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

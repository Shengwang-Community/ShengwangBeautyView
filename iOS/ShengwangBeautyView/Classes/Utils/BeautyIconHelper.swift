//
//  BeautyIconHelper.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

/// UIImage extension for loading beauty icon resources from bundle
public extension UIImage {
    
    /// BeautyView bundle
    /// Load beauty icons from Resources/Icons folder
    /// - Parameter name: Icon name (PNG filename without extension)
    /// - Returns: UIImage object, or nil if not found
    static func beautyIcon(named name: String) -> UIImage? {
        // Merge beautyBundle private property as local variable within method
        let beautyBundle: Bundle? = {
            // First try to find resource bundle from main bundle
            if let bundlePath = Bundle.main.path(forResource: "BeautyView", ofType: "bundle"),
               let bundle = Bundle(path: bundlePath) {
                return bundle
            }

            // Find resource bundle from framework bundle
            let frameworkBundle = Bundle(for: ShengwangBeautyView.self)
            if let bundlePath = frameworkBundle.path(forResource: "BeautyView", ofType: "bundle"),
               let bundle = Bundle(path: bundlePath) {
                return bundle
            }

            return frameworkBundle
        }()
        
        guard let bundle = beautyBundle else {
            return nil
        }

        // Use UIImage(named:in:compatibleWith:) to automatically find resources
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}

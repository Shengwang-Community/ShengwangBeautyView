//
//  StringLocalizer.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation

/// String extension for loading localized strings from bundle for beauty components
public extension String {
    
    /// BeautyView bundle
    /// When using CocoaPods resource_bundles, resources will be packaged into BeautyView.bundle
    private static var beautyBundle: Bundle? {
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
    }
    
    /// Get localized string
    /// - Returns: Localized string, or the key itself if not found
    /// NSLocalizedString will automatically find the corresponding language .lproj directory (e.g., zh-Hans.lproj, en.lproj)
    var localized: String {
        guard let bundle = String.beautyBundle else {
            return self
        }
        
        // Use NSLocalizedString to find localized string
        // NSLocalizedString will automatically find the corresponding .lproj directory based on system language
        let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
        return localizedString
    }
    
    /// Get localized string (with fallback)
    /// - Parameter fallback: Default value to use if localized string is not found
    /// - Returns: Localized string or fallback value
    func localized(fallback: String) -> String {
        let localizedString = self.localized
        return localizedString == self ? fallback : localizedString
    }
}

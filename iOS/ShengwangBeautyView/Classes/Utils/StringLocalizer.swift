//
//  StringLocalizer.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation

/// String extension for loading localized strings from bundle for beauty components
public extension String {
    
    /// Specifiy language for beauty UI, overriding the system language.
    /// Set to a BCP 47 language tag (e.g. "ja", "ko", "fr", "ar") before initializing ShengwangBeautyView.
    /// Set to nil (default) to follow the system language.
    ///
    /// Example:
    ///   String.beautyForcedLanguage = "ja"  // Force Japanese
    ///   String.beautyForcedLanguage = nil   // Follow system language (default)
    public static var beautyForcedLanguage: String? = nil
    
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
    var localized: String {
        guard let bundle = String.beautyBundle else {
            return self
        }
        
        // If a forced language is set, look up the corresponding .lproj bundle
        if let lang = String.beautyForcedLanguage,
           let langPath = bundle.path(forResource: lang, ofType: "lproj"),
           let langBundle = Bundle(path: langPath) {
            return NSLocalizedString(self, bundle: langBundle, comment: "")
        }
        
        // Default: follow system language
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    /// Get localized string (with fallback)
    /// - Parameter fallback: Default value to use if localized string is not found
    /// - Returns: Localized string or fallback value
    func localized(fallback: String) -> String {
        let localizedString = self.localized
        return localizedString == self ? fallback : localizedString
    }
}

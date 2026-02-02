//
//  UIColor+Beauty.swift
//  BeautyView
//
//  Created by Auto on 2026/1/22.
//

import UIKit

internal extension UIColor {
    /// Main accent color (purple) - #7A59FB equivalent
    static var beauty_main_accent: UIColor {
        return UIColor(red: 0x7A / 255.0, green: 0x59 / 255.0, blue: 0xFB / 255.0, alpha: 1.0)
    }
    
    /// Slider tint color (semi-transparent white)
    static var beauty_slider_tint: UIColor {
        return UIColor.white.withAlphaComponent(0.5)
    }
    
    /// Tab deselected text color - #C6C4DD
    static var beauty_tab_deselect: UIColor {
        return UIColor(red: 0xC6 / 255.0, green: 0xC4 / 255.0, blue: 0xDD / 255.0, alpha: 1.0)
    }
    
    /// Tab selected text color (white)
    static var beauty_tab_select: UIColor {
        return .white
    }
    
    /// Dark cover background color
    /// #D9151325 (ARGB format)
    /// RGB: (21, 19, 37), Alpha: 0.85
    static var beauty_dark_cover_bg: UIColor {
        return UIColor(red: 21 / 255.0, green: 19 / 255.0, blue: 37 / 255.0, alpha: 217 / 255.0)
    }
    
    /// Button background color (semi-transparent black)
    static var beauty_button_bg: UIColor {
        return UIColor(hex: "#000000", alpha: 0.25)
    }
    
    /// Convenience initializer for hex color
    /// - Parameters:
    ///   - hex: Hex color string (e.g., "#FF0000" or "FF0000")
    ///   - alpha: Alpha value (0.0 to 1.0)
    internal convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha)
    }
}

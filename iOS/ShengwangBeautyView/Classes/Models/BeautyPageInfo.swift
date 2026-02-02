//
//  BeautyPageInfo.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Beauty module type
/// Corresponds to Agora RTC SDK's VIDEO_EFFECT_NODE_ID
public enum BeautyModule: UInt {
    /// Beauty module (skin beautification + face shape + image quality), value is 1
    case beauty = 1
    /// Style makeup module, value is 2
    case styleMakeup = 2
    /// Filter module, value is 4
    case filter = 4
    /// Sticker module, value is 8
    case sticker = 8
}

/// Beauty item type
public enum BeautyItemType: Equatable {
    /// Normal parameter item (default)
    case normal
    /// Toggle item (e.g., beauty master switch), associated value indicates enabled state
    case toggle(Bool)
    /// Reset item
    case reset
    /// None effect item (e.g., cancel sticker/makeup)
    case none
    
    /// Check if this is a toggle type
    public var isToggle: Bool {
        if case .toggle = self {
            return true
        }
        return false
    }
    
    /// Get toggle value if this is a toggle type, nil otherwise
    public var toggleValue: Bool? {
        if case .toggle(let value) = self {
            return value
        }
        return nil
    }
}

/// Beauty page information
public class BeautyPageInfo {
    /// Page name (localized string key)
    public let name: String
    /// Item list
    public var itemList: [BeautyItemInfo]
    /// Whether selected (for Tab switching)
    public var isSelected: Bool
    /// Page type (corresponds to SDK VIDEO_EFFECT_NODE_ID)
    public let type: BeautyModule
    
    public init(
        name: String,
        itemList: [BeautyItemInfo],
        isSelected: Bool = false,
        type: BeautyModule = .beauty
    ) {
        self.name = name
        self.itemList = itemList
        self.isSelected = isSelected
        self.type = type
    }
}

/// Beauty item information
public class BeautyItemInfo {
    /// Item name (localized string key)
    public var name: String
    /// Item icon
    public var icon: UIImage?
    /// Current value (will be automatically converted for display based on valueRange)
    public var value: Float
    /// Whether selected
    public var isSelected: Bool
    /// Value range (for slider)
    public let valueRange: ClosedRange<Float>
    /// Value change callback (triggered when slider is released)
    public var onValueChanged: ((Float) -> Void)?
    /// Whether to show slider (default is true, should be set to false for items that don't need parameter adjustment)
    public let showSlider: Bool
    /// Item type
    public let type: BeautyItemType
    /// Click callback (triggered when item icon is clicked)
    public var onItemClick: ((BeautyItemInfo) -> Void)?
    
    public init(
        name: String,
        icon: UIImage?,
        value: Float = 0.0,
        isSelected: Bool = false,
        valueRange: ClosedRange<Float> = 0.0...1.0,
        onValueChanged: ((Float) -> Void)? = nil,
        showSlider: Bool = true,
        type: BeautyItemType = .normal,
        onItemClick: ((BeautyItemInfo) -> Void)? = nil
    ) {
        self.name = name
        self.icon = icon
        self.value = value
        self.isSelected = isSelected
        self.valueRange = valueRange
        self.onValueChanged = onValueChanged
        self.showSlider = showSlider
        self.type = type
        self.onItemClick = onItemClick
    }
}

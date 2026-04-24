//
//  BeautyPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Beauty module page builder
/// Responsible for building page information for beauty (skin beautification + face shape + image quality) module
internal class BeautyPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var beautyItems: [BeautyItemInfo] = []
        
        // Basic function items (always displayed)
        // 1. Toggle item (selected means enabled)
        let isBeautyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_effect_enable",
                icon: nil,
                isSelected: false,
                showSlider: false,
                type: .toggle(isBeautyEnabled)
            )
        )
        
        // 2. Reset button
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_effect_reset",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_reset"),
                showSlider: false,
                type: .reset
            )
        )
        
        // 美颜参数（美肤+美型混排，按指定顺序）
        addBeautyItems(&beautyItems)
        
        // Image quality parameters (all commented out, not displayed)
        // addQualityItems(&beautyItems)
        
        return BeautyPageInfo(
            name: "beauty_group_beauty",
            itemList: beautyItems,
            type: .beauty
        )
    }
    
    // MARK: - Private Methods
    
    /// Add all beauty parameters in the specified absolute order (skin + face shape mixed)
    /// Order: whitening, smoothness, redness, slim face, V-face, narrow face, big eyes, eye distance,
    ///        brighten eye, slim cheekbone, slim nose, long nose, mouth shape, chin, slim jawline,
    ///        dark circle removal, nasolabial fold removal
    private func addBeautyItems(_ items: inout [BeautyItemInfo]) {
        // 1. Whitening
        addSkinBeautyItem(&items, name: "beauty_effect_lightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"), value: beautyConfig.whitenNatural, isSelected: beautyConfig.beautyEnable) { [weak self] value in self?.beautyConfig.whitenNatural = value }
        // 2. Smoothness
        addSkinBeautyItem(&items, name: "beauty_effect_smoothness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_smoothness"), value: beautyConfig.smoothness) { [weak self] value in self?.beautyConfig.smoothness = value }
        // 3. Redness
        addSkinBeautyItem(&items, name: "beauty_effect_redness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_redness"), value: beautyConfig.redness) { [weak self] value in self?.beautyConfig.redness = value }
        // 4. Face contour (slim face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_contour", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"), value: Float(beautyConfig.faceContour), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.faceContour = Int32(value) }
        // 5. Mandible (V-shaped face)
        addFaceShapeItem(&items, name: "beauty_face_shape_mandible", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mandible"), value: Float(beautyConfig.mandible), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.mandible = Int32(value) }
        // 6. Face width (narrow face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_width"), value: Float(beautyConfig.faceWidth), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.faceWidth = Int32(value) }
        // 7. Eye scale (enlarge eyes)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_scale"), value: Float(beautyConfig.eyeScale), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.eyeScale = Int32(value) }
        // 8. Eye distance
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_distance", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_distance"), value: Float(beautyConfig.eyeDistance), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyeDistance = Int32(value) }
        // 9. Eye brightening
        addSkinBeautyItem(&items, name: "beauty_effect_brighten_eye", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brighten_eye"), value: beautyConfig.brightenEye) { [weak self] value in self?.beautyConfig.brightenEye = value }
        // 10. Cheekbone (slim cheekbone)
        addFaceShapeItem(&items, name: "beauty_face_shape_cheekbone", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheekbone"), value: Float(beautyConfig.cheekbone), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.cheekbone = Int32(value) }
        // 11. Nose width (slim nose)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_width"), value: Float(beautyConfig.noseWidth), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.noseWidth = Int32(value) }
        // 12. Nose length (lengthen nose)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_length"), value: Float(beautyConfig.noseLength), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.noseLength = Int32(value) }
        // 13. Mouth scale (mouth shape)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_scale"), value: Float(beautyConfig.mouthScale), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.mouthScale = Int32(value) }
        // 14. Chin
        addFaceShapeItem(&items, name: "beauty_face_shape_chin", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_chin"), value: Float(beautyConfig.chin), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.chin = Int32(value) }
        // 15. Cheek (slim jawline)
        addFaceShapeItem(&items, name: "beauty_face_shape_cheek", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheek"), value: Float(beautyConfig.cheek), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.cheek = Int32(value) }
        // 16. Eye bag / dark circle removal
        addSkinBeautyItem(&items, name: "beauty_effect_eye_pouch", icon: UIImage.beautyIcon(named: "beauty_ic_effect_eye_pouch"), value: beautyConfig.eyePouch) { [weak self] value in self?.beautyConfig.eyePouch = value }
        // 17. Nasolabial fold removal
        addSkinBeautyItem(&items, name: "beauty_effect_nasolabial_fold", icon: UIImage.beautyIcon(named: "beauty_ic_effect_nasolabial_fold"), value: beautyConfig.nasolabialFold) { [weak self] value in self?.beautyConfig.nasolabialFold = value }
        
        // The following items are not displayed, commented out
        // Contrast strength — not displayed, commented out
//        addSkinBeautyItem(&items, name: "beauty_effect_contrast_strength", icon: UIImage.beautyIcon(named: "beauty_ic_effect_contrast_strength"), value: beautyConfig.contrastStrength, valueRange: -1.0...1.0) { [weak self] value in self?.beautyConfig.contrastStrength = value }
        // Sharpness — not displayed, commented out
//        addSkinBeautyItem(&items, name: "beauty_effect_sharpness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_sharpness"), value: beautyConfig.sharpness) { [weak self] value in self?.beautyConfig.sharpness = value }
        // Teeth whitening — not displayed, commented out
//        addSkinBeautyItem(&items, name: "beauty_effect_whiten_teeth", icon: UIImage.beautyIcon(named: "beauty_ic_effect_whiten_teeth"), value: beautyConfig.whitenTeeth) { [weak self] value in self?.beautyConfig.whitenTeeth = value }
        // Face length — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_face_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_length"), value: Float(beautyConfig.faceLength), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.faceLength = Int32(value) }
        // Forehead (hairline) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_fore_head", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_fore_head"), value: Float(beautyConfig.foreHead), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.foreHead = Int32(value) }
        // Head scale (small head) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_head_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_head_scale"), value: Float(beautyConfig.headScale), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.headScale = Int32(value) }
        // Nose root — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_nose_root", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_root"), value: Float(beautyConfig.noseRoot), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.noseRoot = Int32(value) }
        // Nose bridge — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_nose_bridge", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_bridge"), value: Float(beautyConfig.noseBridge), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.noseBridge = Int32(value) }
        // Nose tip — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_nose_tip", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_tip"), value: Float(beautyConfig.noseTip), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.noseTip = Int32(value) }
        // Nose wing — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_nose_wing", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_wing"), value: Float(beautyConfig.noseWing), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.noseWing = Int32(value) }
        // Nose general — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_nose_general", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_general"), value: Float(beautyConfig.noseGeneral), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.noseGeneral = Int32(value) }
        // Eye lid (lower eyelid) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_eye_lid", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_lid"), value: Float(beautyConfig.eyeLid), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.eyeLid = Int32(value) }
        // Eye inner corner — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_inner_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_inner_corner"), value: Float(beautyConfig.eyeInnerCorner), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyeInnerCorner = Int32(value) }
        // Eye outer corner — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_outer_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_outer_corner"), value: Float(beautyConfig.eyeOuterCorner), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyeOuterCorner = Int32(value) }
        // Eye position — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_eye_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_position"), value: Float(beautyConfig.eyePosition), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyePosition = Int32(value) }
        // Eye pupils — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_eye_pupils", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_pupils"), value: Float(beautyConfig.eyePupils), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.eyePupils = Int32(value) }
        // Mouth smile (smile lips) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_smile", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_smile"), value: Float(beautyConfig.mouthSmile), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.mouthSmile = Int32(value) }
        // Mouth lip (fuller lips) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_lip", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_lip"), value: Float(beautyConfig.mouthLip), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.mouthLip = Int32(value) }
        // Mouth position (philtrum) — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_position"), value: Float(beautyConfig.mouthPosition), valueRange: 0.0...100.0) { [weak self] value in self?.beautyConfig.mouthPosition = Int32(value) }
        // Eyebrow thickness — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_eyebrow_thickness", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eyebrow_thickness"), value: Float(beautyConfig.eyebrowThickness), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyebrowThickness = Int32(value) }
        // Eyebrow position — not displayed, commented out
//        addFaceShapeItem(&items, name: "beauty_face_shape_eyebrow_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eyebrow_position"), value: Float(beautyConfig.eyebrowPosition), valueRange: -100.0...100.0) { [weak self] value in self?.beautyConfig.eyebrowPosition = Int32(value) }
    }
    
    /// Add image quality parameters
    private func addQualityItems(_ items: inout [BeautyItemInfo]) {
        // Color temperature
        addQualityItem(&items, name: "beauty_effect_temperature", icon: UIImage.beautyIcon(named: "beauty_ic_effect_temperature"), value: beautyConfig.temperature) { [weak self] value in
            self?.beautyConfig.temperature = value
        }
        
        // Hue
        addQualityItem(&items, name: "beauty_effect_hue", icon: UIImage.beautyIcon(named: "beauty_ic_effect_hue"), value: beautyConfig.hue) { [weak self] value in
            self?.beautyConfig.hue = value
        }
        
        // Saturation
        addQualityItem(&items, name: "beauty_effect_saturation", icon: UIImage.beautyIcon(named: "beauty_ic_effect_saturation"), value: beautyConfig.saturation) { [weak self] value in
            self?.beautyConfig.saturation = value
        }
        
        // Brightness
        addQualityItem(&items, name: "beauty_effect_brightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brightness"), value: beautyConfig.brightness) { [weak self] value in
            self?.beautyConfig.brightness = value
        }
    }
    
    // MARK: - Helper Methods
    
    private func addSkinBeautyItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        isSelected: Bool = false,
        valueRange: ClosedRange<Float> = 0.0...1.0,
        onValueChanged: @escaping (Float) -> Void
    ) {
        let isBipolar = valueRange.lowerBound < 0
        // UI 显示范围和换算
        let uiRange: ClosedRange<Float> = isBipolar ? -50.0...50.0 : 0.0...100.0
        let uiValue: Float = isBipolar ? value * 50.0 : value * 100.0
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: uiValue,
                isSelected: isSelected,
                valueRange: uiRange,
                onValueChanged: { uiVal in
                    let sdkValue = isBipolar ? uiVal / 50.0 : uiVal / 100.0
                    onValueChanged(sdkValue)
                }
            )
        )
    }
    
    private func addFaceShapeItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        valueRange: ClosedRange<Float> = 0.0...100.0,
        onValueChanged: @escaping (Float) -> Void
    ) {
        let isBipolar = valueRange.lowerBound < 0
        // UI display conversion: SDK -100~100 → UI -50~50; 0~100 unchanged
        let uiRange: ClosedRange<Float> = isBipolar ? -50.0...50.0 : valueRange
        let uiValue: Float = isBipolar ? value / 2.0 : value
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: uiValue,
                valueRange: uiRange,
                onValueChanged: { uiVal in
                    let sdkValue = isBipolar ? uiVal * 2.0 : uiVal
                    onValueChanged(sdkValue)
                }
            )
        )
    }
    
    private func addQualityItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        valueRange: ClosedRange<Float> = -1.0...1.0,
        onValueChanged: @escaping (Float) -> Void
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: value * 50.0,  // -1.0~1.0 → -50~50
                valueRange: -50.0...50.0,
                onValueChanged: { uiVal in
                    onValueChanged(uiVal / 50.0)  // -50~50 → -1.0~1.0
                }
            )
        )
    }
}

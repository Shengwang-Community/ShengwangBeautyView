//
//  ShengwangBeautySDK.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import AgoraRtcKit

/// Shengwang Beauty SDK
///
/// Resource update instructions:
/// If beauty resource files are updated, you need to clear the app's UserDefaults data
/// or uninstall and reinstall the app, otherwise the SDK will think the resources have been copied
/// and will not copy the updated resources again.
@objc public class ShengwangBeautySDK: NSObject {
    
    // MARK: - Singleton
    
    @objc public static let shared = ShengwangBeautySDK()
    
    // MARK: - Properties
    
    private var rtcEngine: AgoraRtcEngineKit?
    private var beautyEffect: AgoraVideoEffectObject?
    
    private var beautyEnable = false
    private var filterEnable = false
    private var makeupEnable = false
    private var stickerEnable = false
    
    /// State listener (Swift). For Objective-C use setBeautyStateListener(_:).
    public var beautyStateListener: (() -> Void)?
    
    /// Beauty configuration (internal; used by ShengwangBeautyView and builders)
    internal lazy var beautyConfig: BeautyConfig = {
        return BeautyConfig(sdk: self)
    }()
    
    // MARK: - BeautyConfig (Nested Class)
    
    /// Beauty configuration class (internal; not part of public API)
    internal class BeautyConfig {
        
        // MARK: - Properties
        
        private weak var sdk: ShengwangBeautySDK?
        
        // MARK: - Initialization
        
        internal init(sdk: ShengwangBeautySDK) {
            self.sdk = sdk
        }
        
        // MARK: - Internal Properties Access
        
        private var parentBeautyEffect: AgoraVideoEffectObject? {
            return sdk?.beautyEffect
        }
        
        private var parentRtcEngine: AgoraRtcEngineKit? {
            return sdk?.rtcEngine
        }
        
        private var parentBeautyEnable: Bool {
            return sdk?.beautyEnable ?? false
        }
        
        private var filterEnable: Bool {
            return sdk?.filterEnable ?? false
        }
        
        private var makeupEnable: Bool {
            return sdk?.makeupEnable ?? false
        }
        
        private var stickerEnable: Bool {
            return sdk?.stickerEnable ?? false
        }
        
        // MARK: - Beauty Parameters
        
        /// Beauty template name, empty string means default material
        public var beautyName: String = "" {
            didSet {
                if oldValue == beautyName { return }
                parentBeautyEffect?.addOrUpdateVideoEffect(nodeId: BeautyModule.beauty.rawValue, templateName: beautyName)
            }
        }
        
        /// Enable/disable basic beauty + skin beautification + image quality
        public var beautyEnable: Bool {
            get {
                let value = parentBeautyEffect?.getVideoEffectBoolParam(option: "beauty_effect_option", key: "enable") ?? false
                return value
            }
            set {
                parentBeautyEffect?.setVideoEffectBoolParam(option: "beauty_effect_option", key: "enable", boolValue: newValue)
                sdk?.notifyBeautyStateChanged()
            }
        }
        
        /// Smoothness intensity, range: [0.0, 1.0]
        public var smoothness: Float {
            get {
                let value = parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "smoothness") ?? 0.7
                return value
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "smoothness", floatValue: newValue)
            }
        }
        
        /// Whitening intensity, range: [0.0, 1.0]
        public var whitenNatural: Float {
            get {
                let value = parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "lightness") ?? 0.7
                return value
            }
            set {
                parentBeautyEffect?.setVideoEffectStringParam(option: "beauty_effect_option", key: "whiten_lut_path", stringValue: "")
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "lightness", floatValue: newValue)
            }
        }
        
        /// Redness intensity, range: [0.0, 1.0]
        public var redness: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "redness") ?? 0.3
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "redness", floatValue: newValue)
            }
        }
        
        /// Sharpness intensity, range: [0.0, 1.0]
        public var sharpness: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "sharpness") ?? 0.6
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "sharpness", floatValue: newValue)
            }
        }
        
        /// Contrast strength intensity, range: [-1.0, 1.0]
        public var contrastStrength: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "contrast_strength") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "contrast_strength", floatValue: newValue)
            }
        }
        
        /// Teeth whitening intensity, range: [0.0, 1.0]
        public var whitenTeeth: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "face_buffing_option", key: "whiten_teeth") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "face_buffing_option", key: "whiten_teeth", floatValue: newValue)
            }
        }
        
        /// Nasolabial fold removal intensity, range: [0.0, 1.0]
        public var nasolabialFold: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "face_buffing_option", key: "nasolabial_fold") ?? 0.8
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "face_buffing_option", key: "nasolabial_fold", floatValue: newValue)
            }
        }
        
        /// Eye brightening intensity, range: [0.0, 1.0]
        public var brightenEye: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "face_buffing_option", key: "brighten_eye") ?? 0.8
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "face_buffing_option", key: "brighten_eye", floatValue: newValue)
            }
        }
        
        /// Eye bag/dark circle removal intensity, range: [0.0, 1.0]
        public var eyePouch: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "face_buffing_option", key: "eye_pouch") ?? 0.8
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "face_buffing_option", key: "eye_pouch", floatValue: newValue)
            }
        }
        
        // MARK: - Image Quality Parameters
        
        /// Color temperature intensity, range: [-1.0, 1.0]
        public var temperature: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "temperature") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "temperature", floatValue: newValue)
            }
        }
        
        /// Hue intensity, range: [-1.0, 1.0]
        public var hue: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "hue") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "hue", floatValue: newValue)
            }
        }
        
        /// Saturation intensity, range: [-1.0, 1.0]
        public var saturation: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "saturation") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "saturation", floatValue: newValue)
            }
        }
        
        /// Brightness intensity, range: [-1.0, 1.0]
        public var brightness: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "brightness") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "brightness", floatValue: newValue)
            }
        }
        
        // MARK: - Face Shape Parameters
        
        /// Enable/disable face shape adjustment
        public var faceShapeEnable: Bool {
            get {
                let value = parentBeautyEffect?.getVideoEffectBoolParam(option: "face_shape_beauty_option", key: "enable") ?? false
                return value
            }
            set {
                parentBeautyEffect?.setVideoEffectBoolParam(option: "face_shape_beauty_option", key: "enable", boolValue: newValue)
                sdk?.notifyBeautyStateChanged()
            }
        }
        
        /// Face shape style: -1(none); 0(goddess); 1(god); 2(natural)
        public var faceShapeStyle: Int32 {
            get {
                return parentBeautyEffect?.getVideoEffectIntParam(option: "face_shape_beauty_option", key: "style") ?? 0
            }
            set {
                parentBeautyEffect?.setVideoEffectIntParam(option: "face_shape_beauty_option", key: "style", intValue: newValue)
            }
        }
        
        /// Face shape style intensity, range: [0, 100]
        public var faceShapeIntensity: Int32 {
            get {
                return parentBeautyEffect?.getVideoEffectIntParam(option: "face_shape_beauty_option", key: "intensity") ?? 0
            }
            set {
                parentBeautyEffect?.setVideoEffectIntParam(option: "face_shape_beauty_option", key: "intensity", intValue: newValue)
            }
        }
        
        /// Head scale, range: [0, 100], shrink entire head
        public var headScale: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.headScale)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .headScale
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Forehead/hairline, range: [0, 100], lower hairline
        public var foreHead: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.forehead)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .forehead
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Face contour (slim face), range: [0, 100], shrink entire face outline
        public var faceContour: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.faceContour)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .faceContour
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Mandible (V-face), range: [0, 100], V-face effect
        public var mandible: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.mandible)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .mandible
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Chin, range: [-100, 100], lengthen (positive) or shrink (negative) chin
        public var chin: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.chin)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .chin
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Cheek (jawline), range: [0, 100], shrink jawline
        public var cheek: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.cheek)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .cheek
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Cheekbone (slim cheekbone), range: [0, 100], compress cheekbone
        public var cheekbone: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.cheekbone)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .cheekbone
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Face length, range: [-100, 100], vertical face stretch: positive lengthen, negative shorten
        public var faceLength: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.faceLength)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .faceLength
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Face width (narrow face), range: [0, 100], horizontally narrow face
        public var faceWidth: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.faceWidth)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .faceWidth
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose width (slim nose), range: [0, 100], slim nose effect
        public var noseWidth: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseWidth)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseWidth
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose root, range: [0, 100], shrink nose root
        public var noseRoot: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseRoot)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseRoot
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose bridge, range: [0, 100], shrink nose bridge
        public var noseBridge: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseBridge)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseBridge
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose tip, range: [0, 100], shrink nose tip
        public var noseTip: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseTip)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseTip
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose wing, range: [0, 100], shrink nose wing
        public var noseWing: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseWing)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseWing
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose length, range: [-100, 100], lengthen nose: positive lengthen, negative shorten
        public var noseLength: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseLength)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseLength
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Nose general, range: [-100, 100], overall nose shrink: positive shrink, negative enlarge
        public var noseGeneral: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.noseGeneral)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .noseGeneral
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye scale (enlarge eyes), range: [0, 100], enlarge entire eyes
        public var eyeScale: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyeScale)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyeScale
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye distance, range: [-100, 100], adjust eye distance: positive narrow, negative widen
        public var eyeDistance: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyeDistance)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyeDistance
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye lid (lower eyelid), range: [0, 100], lower eyelid outward effect
        public var eyeLid: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.lowerEyelid)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .lowerEyelid
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye inner corner, range: [-100, 100], inner corner position: positive toward nose, negative opposite
        public var eyeInnerCorner: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyeInnerCorner)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyeInnerCorner
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye outer corner, range: [-100, 100], outer corner position: positive outward, negative inward
        public var eyeOuterCorner: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyeOuterCorner)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyeOuterCorner
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye position, range: [-100, 100], vertical eye adjustment: positive up, negative down
        public var eyePosition: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyePosition)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyePosition
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eye pupils, range: [0, 100], enlarge pupils
        public var eyePupils: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyePupils)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyePupils
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Mouth smile, range: [0, 100], smile intensity
        public var mouthSmile: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.mouthSmile)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .mouthSmile
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Mouth lip (fuller lips), range: [0, 100], fuller lip effect
        public var mouthLip: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.mouthLip)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .mouthLip
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Mouth scale, range: [-100, 100], mouth scale: positive enlarge, negative shrink
        public var mouthScale: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.mouthScale)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .mouthScale
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Mouth position (philtrum), range: [0, 100], vertical mouth position: positive up
        public var mouthPosition: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.mouthPosition)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .mouthPosition
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eyebrow thickness, range: [-100, 100], eyebrow thickness: positive thicker, negative thinner
        public var eyebrowThickness: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyebrowThickness)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyebrowThickness
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        /// Eyebrow position, range: [-100, 100], vertical eyebrow position: positive up, negative down
        public var eyebrowPosition: Int32 {
            get {
                return parentRtcEngine?.getFaceShapeAreaOptions(.eyebrowPosition)?.shapeIntensity ?? 0
            }
            set {
                let areaOption = AgoraFaceShapeAreaOptions()
                areaOption.shapeArea = .eyebrowPosition
                areaOption.shapeIntensity = newValue
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        }
        
        // MARK: - Style Makeup Parameters
        
        /// Style makeup material name
        public var makeupName: String? {
            didSet {
                if oldValue == makeupName { return }
                if makeupName == nil {
                    parentBeautyEffect?.removeVideoEffect(nodeId: BeautyModule.styleMakeup.rawValue)
                } else if makeupEnable, let name = makeupName {
                    parentBeautyEffect?.addOrUpdateVideoEffect(nodeId: BeautyModule.styleMakeup.rawValue, templateName: name)
                }
            }
        }
        
        /// Makeup intensity cache Map
        /// key: Makeup template name (makeupName)
        /// value: Intensity value for that template [0.0, 1.0]
        ///
        /// Purpose: Record intensity value for each makeup template, maintain user-set intensity when switching templates
        /// Clear timing: Cleared in unInitBeautySDK() to ensure next initialization won't use old data
        internal var makeupIntensityMap: [String: Float] = [:]
        
        /// Style makeup intensity, range: [0.0, 1.0]
        ///
        /// Get logic:
        /// 1. If no makeup template is selected, return 0f
        /// 2. Priority: read from cache makeupIntensityMap
        /// 3. Cache miss: read from parentBeautyEffect and update cache
        ///
        /// Set logic:
        /// 1. Update cache for current template's intensity value
        /// 2. Synchronously update underlying effect parameters
        public var makeupIntensity: Float {
            get {
                guard let currentMakeupName = makeupName else { return 0.0 }
                
                // Priority: read from cache
                if let cacheIntensity = makeupIntensityMap[currentMakeupName] {
                    return cacheIntensity
                }
                
                // Cache miss: read from parentBeautyEffect and update cache
                let strength = parentBeautyEffect?.getVideoEffectFloatParam(option: "style_makeup_option", key: "styleIntensity") ?? 0.0
                print("[BeautySDK] makeupIntensity \(strength) for \(currentMakeupName)")
                
                // Store read value in cache to avoid repeated reads
                makeupIntensityMap[currentMakeupName] = strength
                return strength
            }
            set {
                // Update cache and underlying effect parameters
                if let name = makeupName {
                    makeupIntensityMap[name] = newValue
                    parentBeautyEffect?.setVideoEffectFloatParam(option: "style_makeup_option", key: "styleIntensity", floatValue: newValue)
                }
            }
        }
        
        /// Get intensity value for specified makeup template
        /// Priority: read from cache, return nil if cache miss (to distinguish "user never set" from "user set to 0")
        /// - Parameter templateName: Makeup template name
        /// - Returns: Intensity value for that template, or nil if not in cache
        public func getMakeupIntensityForTemplate(_ templateName: String) -> Float? {
            return makeupIntensityMap[templateName]
        }
        
        /// Style makeup filter strength, range: [0.0, 1.0]
        public var makeupFilterStrength: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "style_makeup_option", key: "filterStrength") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "style_makeup_option", key: "filterStrength", floatValue: newValue)
            }
        }
        
        // MARK: - Filter Parameters
        
        /// Filter template name
        public var filterName: String? {
            didSet {
                if oldValue == filterName { return }
                if filterName == nil {
                    parentBeautyEffect?.removeVideoEffect(nodeId: BeautyModule.filter.rawValue)
                }
                if filterEnable, let name = filterName {
                    parentBeautyEffect?.addOrUpdateVideoEffect(nodeId: BeautyModule.filter.rawValue, templateName: name)
                }
            }
        }
        
        /// Filter strength cache Map
        /// key: Filter template name (filterName)
        /// value: Strength value for that template [0.0, 1.0]
        ///
        /// Purpose: Record strength value for each filter template, maintain user-set strength when switching templates
        /// Clear timing: Cleared in unInitBeautySDK() to ensure next initialization won't use old data
        internal var filterStrengthMap: [String: Float] = [:]
        
        /// Filter strength, range: [0.0, 1.0]
        public var filterStrength: Float {
            get {
                guard let currentFilterName = filterName else { return 0.0 }
                
                // Priority: read from cache
                if let cacheIntensity = filterStrengthMap[currentFilterName] {
                    return cacheIntensity
                }
                
                // Cache miss: read from parentBeautyEffect and update cache
                let strength = parentBeautyEffect?.getVideoEffectFloatParam(option: "filter_effect_option", key: "strength") ?? 0.0
                print("[BeautySDK] filterStrength \(strength)")
                
                // Store read value in cache to avoid repeated reads
                filterStrengthMap[currentFilterName] = strength
                return strength
            }
            set {
                // Update cache and underlying effect parameters
                if let name = filterName {
                    filterStrengthMap[name] = newValue
                    parentBeautyEffect?.setVideoEffectFloatParam(option: "filter_effect_option", key: "strength", floatValue: newValue)
                }
            }
        }
        
        /// Get strength value for specified filter template
        /// Priority: read from cache, return nil if cache miss (to distinguish "user never set" from "user set to 0")
        /// - Parameter templateName: Filter template name
        /// - Returns: Strength value for that template, or nil if not in cache
        public func getFilterStrengthForTemplate(_ templateName: String) -> Float? {
            return filterStrengthMap[templateName]
        }
        
        // MARK: - Sticker Parameters
        
        /// Sticker material name
        public var stickerName: String? {
            didSet {
                if oldValue == stickerName { return }
                if stickerName == nil {
                    parentBeautyEffect?.removeVideoEffect(nodeId: BeautyModule.sticker.rawValue)
                }
                if stickerEnable, let name = stickerName {
                    parentBeautyEffect?.addOrUpdateVideoEffect(nodeId: BeautyModule.sticker.rawValue, templateName: name)
                }
            }
        }
        
        /// Sticker strength, range: [0.0, 1.0]
        public var stickerStrength: Float {
            get {
                return parentBeautyEffect?.getVideoEffectFloatParam(option: "sticker_effect_option", key: "strength") ?? 0.0
            }
            set {
                parentBeautyEffect?.setVideoEffectFloatParam(option: "sticker_effect_option", key: "strength", floatValue: newValue)
            }
        }
        
        // MARK: - Reset and Save
        
        /// Reset beauty parameters
        /// - Parameter nodeId: Node ID (corresponds to BeautyModule)
        internal func resetBeauty(_ nodeId: BeautyModule = .beauty) {
            parentBeautyEffect?.performVideoEffectAction(nodeId: nodeId.rawValue, actionId: AgoraVideoEffectAction.reset)
        }
        
        /// Save beauty parameters
        /// - Parameter nodeId: Node ID (corresponds to BeautyModule)
        internal func saveBeauty(_ nodeId: BeautyModule = .beauty) {
            parentBeautyEffect?.performVideoEffectAction(nodeId: nodeId.rawValue, actionId: AgoraVideoEffectAction.save)
        }
    }
    
    // MARK: - Public Methods
    
    /// Initialize beauty SDK with external AgoraBeautyMaterial.bundle path
    /// Caller must provide the path to AgoraBeautyMaterial.bundle (obtain from technical support).
    /// - Parameters:
    ///   - rtcEngine: Agora RTC Engine instance
    ///   - materialBundlePath: Full path to AgoraBeautyMaterial.bundle (e.g. from Bundle.main or app sandbox)
    /// - Returns: Whether initialization succeeded
    @discardableResult
    @objc public func initBeautySDK(rtcEngine: AgoraRtcEngineKit, materialBundlePath: String) -> Bool {
        guard !materialBundlePath.isEmpty, FileManager.default.fileExists(atPath: materialBundlePath) else {
            print("[BeautySDK] ERROR: Invalid or missing material bundle path: \(materialBundlePath)")
            return false
        }
        
        // Check if beauty_material_functional directory exists
        let functionalPath = (materialBundlePath as NSString).appendingPathComponent("beauty_material_functional")
        let materialPath = FileManager.default.fileExists(atPath: functionalPath) ? functionalPath : materialBundlePath
        
        if !FileManager.default.fileExists(atPath: functionalPath) {
            print("[BeautySDK] beauty_material_functional not found, using bundle path directly")
        }
        
        return initBeautySDKInternal(materialPath: materialPath, rtcEngine: rtcEngine)
    }
    
    /// Internal method to initialize beauty SDK with material path
    /// - Parameters:
    ///   - materialPath: Beauty resource file path
    ///   - rtcEngine: Agora RTC Engine instance
    /// - Returns: Whether initialization succeeded
    private func initBeautySDKInternal(materialPath: String, rtcEngine: AgoraRtcEngineKit) -> Bool {
        self.rtcEngine = rtcEngine
        
        // Enable extension
        let ret = rtcEngine.enableExtension(
            withVendor: "agora_video_filters_clear_vision",
            extension: "clear_vision",
            enabled: true,
            sourceType: .primaryCamera
        )
        
        if ret != 0 {
            print("[BeautySDK] enableExtension failed: errorCode: \(ret)")
            self.rtcEngine = nil
            return false
        }
        
        // Create VideoEffectObject
        // iOS: agorakit.createVideoEffectObject(bundlePath:sourceType:)
        beautyEffect = rtcEngine.createVideoEffectObject(
            bundlePath: materialPath,
            sourceType: .primaryCamera
        )
        
        if beautyEffect == nil {
            print("[BeautySDK] Failed to create VideoEffectObject")
            self.rtcEngine = nil
            return false
        }
        
        // Enable beauty by default
        enable(true)
        
        print("[BeautySDK] Beauty SDK initialized successfully")
        notifyBeautyStateChanged()
        return true
    }
    
    /// Uninitialize beauty SDK
    @objc public func unInitBeautySDK() {
        enable(false)
        
        // Destroy beautyEffect before disabling extension
        if let effect = beautyEffect {
            rtcEngine?.destroyVideoEffectObject(effect)
        }
        
        rtcEngine?.enableExtension(
            withVendor: "agora_video_filters_clear_vision",
            extension: "clear_vision",
            enabled: false,
            sourceType: .primaryCamera
        )
        
        rtcEngine = nil
        beautyEffect = nil
        beautyEnable = false
        filterEnable = false
        makeupEnable = false
        stickerEnable = false
        
        // Clear all configuration values to ensure next initialization won't automatically apply previous effects
        // Note: At this point beautyEffect has been set to nil, operations in setters won't execute, but field values will be reset
        beautyConfig.stickerName = nil
        beautyConfig.filterName = nil
        beautyConfig.makeupName = nil
        beautyConfig.beautyName = ""
        beautyConfig.makeupIntensityMap.removeAll()
        beautyConfig.filterStrengthMap.removeAll()
        
        print("[BeautySDK] unInitBeautySDK")
        notifyBeautyStateChanged()
    }
    
    /// Set state listener from Objective-C (block callback when beauty state changes).
    @objc public func setBeautyStateListener(_ block: (() -> Void)?) {
        beautyStateListener = block
    }
    
    /// Enable/disable beauty
    /// - Parameter enable: Whether to enable
    @objc public func enable(_ enable: Bool) {
        if enable {
            enableBeauty(true)
            enableFilter(true)
            enableMakeup(true)
            enableSticker(true)
        } else {
            enableBeauty(false)
            enableFilter(false)
            enableMakeup(false)
            enableSticker(false)
        }
    }
    
    /// Set filter effect
    /// Reference: Similar to BeautyManager.setFilter in show scene
    /// - Parameters:
    ///   - path: Filter resource path (relative path from material directory)
    ///   - key: Filter key/name (optional, can be used for identification)
    ///   - value: Filter strength, range: [0.0, 1.0]
    public func setFilter(path: String?, key: String?, value: CGFloat) {
        guard let path = path else {
            // Remove filter if path is nil
            beautyConfig.filterName = nil
            enableFilter(false)
            return
        }
        
        // Set filter name and strength
        // Note: Setting beautyConfig.filterName will trigger didSet in BeautyConfig
        // which will call addOrUpdateVideoEffect if filter is enabled
        beautyConfig.filterName = path
        beautyConfig.filterStrength = Float(value)
        
        // Ensure filter is enabled
        if !filterEnable {
            enableFilter(true)
        } else {
            // Force update by calling enableFilter again
            // This will trigger the update logic in enableFilter
            updateFilter()
        }
    }
    
    /// Set sticker effect
    /// Reference: Similar to BeautyManager.setSticker in show scene
    /// - Parameter path: Sticker resource path (relative path from material directory)
    public func setSticker(path: String?) {
        if path == nil {
            // Remove sticker if path is nil
            beautyConfig.stickerName = nil
            enableSticker(false)
        } else {
            // Set sticker name
            // Note: Setting beautyConfig.stickerName will trigger didSet in BeautyConfig
            // which will call addOrUpdateVideoEffect if sticker is enabled
            beautyConfig.stickerName = path
            
            // Ensure sticker is enabled
            if !stickerEnable {
                enableSticker(true)
            } else {
                // Force update by calling updateSticker
                updateSticker()
            }
        }
    }
    
    // MARK: - Update Methods
    
    /// Update filter effect (called when filter is already enabled but needs update)
    private func updateFilter() {
        guard let effect = beautyEffect else { return }
        if let filterName = beautyConfig.filterName {
            effect.addOrUpdateVideoEffect(nodeId: BeautyModule.filter.rawValue, templateName: filterName)
        }
    }
    
    /// Update sticker effect (called when sticker is already enabled but needs update)
    private func updateSticker() {
        guard let effect = beautyEffect else { return }
        if let stickerName = beautyConfig.stickerName {
            effect.addOrUpdateVideoEffect(nodeId: BeautyModule.sticker.rawValue, templateName: stickerName)
        }
    }
    
    // MARK: - Private Methods
    
    private func enableBeauty(_ enable: Bool) {
        guard let effect = beautyEffect else { return }
        if enable == beautyEnable { return }
        
        if enable {
            effect.addOrUpdateVideoEffect(nodeId: BeautyModule.beauty.rawValue, templateName: beautyConfig.beautyName)
        } else {
            effect.removeVideoEffect(nodeId: BeautyModule.beauty.rawValue)
        }
        
        beautyEnable = enable
    }
    
    internal func enableFilter(_ enable: Bool) {
        guard let effect = beautyEffect else { return }
        if enable == filterEnable { return }
        
        if enable {
            if let filterName = beautyConfig.filterName {
                effect.addOrUpdateVideoEffect(nodeId: BeautyModule.filter.rawValue, templateName: filterName)
            }
        } else {
            effect.removeVideoEffect(nodeId: BeautyModule.filter.rawValue)
        }
        
        filterEnable = enable
    }
    
    private func enableMakeup(_ enable: Bool) {
        guard let effect = beautyEffect else { return }
        if enable == makeupEnable { return }
        
        if enable {
            if let makeupName = beautyConfig.makeupName {
                effect.addOrUpdateVideoEffect(nodeId: BeautyModule.styleMakeup.rawValue, templateName: makeupName)
            }
        } else {
            effect.removeVideoEffect(nodeId: BeautyModule.styleMakeup.rawValue)
        }
        
        makeupEnable = enable
    }
    
    internal func enableSticker(_ enable: Bool) {
        guard let effect = beautyEffect else {
            return
        }
        if enable == stickerEnable {
            return
        }
        if enable {
            if let stickerName = beautyConfig.stickerName {
                effect.addOrUpdateVideoEffect(nodeId: BeautyModule.sticker.rawValue, templateName: stickerName)
            }
        } else {
            effect.removeVideoEffect(nodeId: BeautyModule.sticker.rawValue)
        }
        stickerEnable = enable
    }
    
    internal func notifyBeautyStateChanged() {
        beautyStateListener?()
    }
}

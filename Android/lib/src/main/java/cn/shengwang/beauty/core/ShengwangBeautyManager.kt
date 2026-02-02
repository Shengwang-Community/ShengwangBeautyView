package cn.shengwang.beauty.core

import android.util.Log
import io.agora.rtc2.Constants
import io.agora.rtc2.IVideoEffectObject
import io.agora.rtc2.RtcEngine
import io.agora.rtc2.video.FaceShapeAreaOptions

/**
 * 声网美颜管理器
 * 负责管理美颜功能的初始化、配置和生命周期
 *
 * 资源更新说明：
 * 如果更新了 assets/beauty_agora 目录下的美颜资源文件，需要清除应用的 SharedPreferences 数据
 * 或卸载重装应用，否则管理器会认为资源已复制过，不会重新复制更新的资源。
 */
object ShengwangBeautyManager {
    private const val TAG = "ShengwangBeautyManager"
    private var rtcEngine: RtcEngine? = null
    private var beautyEffect: IVideoEffectObject? = null

    private var beautyEnable = false
    private var filterEnable = false
    private var makeupEnable = false
    private var stickerEnable = false

    // 状态监听器
    var beautyStateListener: (() -> Unit)? = null

    /**
     * 通知监听器状态已变化
     */
    private fun notifyBeautyStateChanged() {
        beautyStateListener?.invoke()
    }

    // 美颜配置
    internal val beautyConfig = BeautyConfig()

    /**
     * 检查美颜 SDK 是否已初始化
     * @return true 表示已初始化，false 表示未初始化
     */
    internal fun isInitialized(): Boolean {
        return beautyEffect != null && rtcEngine != null
    }

    fun initBeautySDK(materialPath: String, rtcEngine: RtcEngine): Boolean {
        this.rtcEngine = rtcEngine
        // Enable extension (may already be enabled, but it's safe to call again)
        val ret = rtcEngine.enableExtension(
            "agora_video_filters_clear_vision", "clear_vision", true, Constants.MediaSourceType.PRIMARY_CAMERA_SOURCE
        )
        if (ret != Constants.ERR_OK) {
            Log.e(TAG, "enableExtension failed: errorMsg:${RtcEngine.getErrorDescription(ret)},errorCode:$ret")
            this.rtcEngine = null
            return false
        }

        // Create VideoEffectObject
        beautyEffect = rtcEngine.createVideoEffectObject(materialPath, Constants.MediaSourceType.PRIMARY_CAMERA_SOURCE)
        if (beautyEffect == null) {
            Log.e(TAG, "Failed to create VideoEffectObject")
            this.rtcEngine = null
            return false
        }

        // Enable beauty by default
        enable(true)

        Log.d(TAG, "Beauty manager initialized successfully")
        notifyBeautyStateChanged()
        return true
    }

    fun unInitBeautySDK() {
        try {
            // 先禁用所有效果（统一移除所有效果节点并更新内部标志）
            enable(false)
            
            // Destroy beautyEffect before disabling extension
            beautyEffect?.let { effect ->
                rtcEngine?.destroyVideoEffectObject(effect)
            }
            
            rtcEngine?.enableExtension(
                "agora_video_filters_clear_vision",
                "clear_vision",
                false,
                Constants.MediaSourceType.PRIMARY_CAMERA_SOURCE
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error during unInitBeautySDK", e)
        } finally {
            rtcEngine = null
            // Clear beautyEffect reference
            beautyEffect = null
            
            // 重置所有配置值，确保下次初始化时不会自动应用之前的效果
            // 注意：此时 beautyEffect 已被设置为 null，setter 中的操作不会执行，但字段值会被重置
            beautyConfig.stickerName = null
            beautyConfig.filterName = null
            beautyConfig.makeupName = null
            beautyConfig.beautyName = ""
            beautyConfig.makeupIntensityMap.clear()
            beautyConfig.filterStrengthMap.clear()

            // 注意：beautyEnable, filterEnable, makeupEnable, stickerEnable 已在 enable(false) 中设置为 false
            // 如果 enable(false) 执行失败，这些标志可能仍为 true，但 beautyEffect 已被清空，不会造成影响
            
            Log.d(TAG, "unInitBeautySDK")
            notifyBeautyStateChanged()
        }
    }

    fun enable(enable: Boolean) {
        if (enable) {
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

    private fun enableBeauty(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == beautyEnable) return
        if (enable) {
            effect.addOrUpdateVideoEffect(
                IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value, beautyConfig.beautyName
            )
            beautyConfig.beautyEnable = true
            beautyConfig.faceShapeEnable = true
        } else {
            effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value)
        }
        this.beautyEnable = enable
    }

    private fun enableFilter(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == filterEnable) return
        if (enable) {
            if (beautyConfig.filterName != null) {
                effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value, beautyConfig.filterName
                )
            }
        } else {
            effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value)
        }
        this.filterEnable = enable
    }

    private fun enableMakeup(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == makeupEnable) return
        if (enable) {
            if (beautyConfig.makeupName != null) {
                effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value, beautyConfig.makeupName
                )
            }
        } else {
            effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value)
        }
        this.makeupEnable = enable
    }

    private fun enableSticker(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == stickerEnable) return
        if (enable) {
            if (beautyConfig.stickerName != null) {
                effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value, beautyConfig.stickerName
                )
            }
        } else {
            effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value)
        }
        this.stickerEnable = enable
    }

    internal class BeautyConfig() {
        // Internal references to access parent object's properties
        private val parentBeautyEffect: IVideoEffectObject? get() = beautyEffect
        private val parentRtcEngine: RtcEngine? get() = rtcEngine

        // =================================== 美颜 start ==========================
        // 美颜模板，空字符串表示素材默认
        var beautyName: String = ""
            set(value) {
                if (field == value) {
                    return
                }
                field = value
                parentBeautyEffect?.addOrUpdateVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value, value)
            }

        // 打开/关闭基础美颜+美肤+画质
        var beautyEnable: Boolean = false
            get() = parentBeautyEffect?.getVideoEffectBoolParam("beauty_effect_option", "enable") ?: false
            set(value) {
                field = value
                // Just set the parameter, don't call addOrUpdateVideoEffect to avoid overriding beauty effect
                parentBeautyEffect?.setVideoEffectBoolParam("beauty_effect_option", "enable", value)
                notifyBeautyStateChanged()
            }

        // 磨皮 强度，取值范围为 [0.0,1.0]。
        var smoothness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "smoothness") ?: 0.7f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "smoothness", value)
            }

        // 美白 强度，取值范围为 [0.0,1.0]。
        var whitenNatural: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "lightness") ?: 0.7f
            set(value) {
                field = value
                // string 自定义美白滤镜的相对路径
                // 此功能支持客户自定义切换
                // 声网默认素材包中
                // 冷白："../resource/whiten/lengbai.png"
                // 粉白："../resource/whiten/fenbai.png"
                // 超白："../resource/whiten/chaobai.png
                // "默认自然白：""
                parentBeautyEffect?.setVideoEffectStringParam("beauty_effect_option", "whiten_lut_path", "")
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "lightness", value)
            }

        // 红润 强度，取值范围为 [0.0,1.0]。
        var redness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "redness") ?: 0.3f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "redness", value)
            }

        // 锐化 强度，取值范围为 [0.0,1.0]。
        var sharpness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "sharpness") ?: 0.6f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "sharpness", value)
            }

        // 清晰度 强度，取值范围为 [-1.0,1.0]。
        var contrastStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "contrast_strength") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "contrast_strength", value)
            }

        // 白牙 强度 取值范围为 [0.0,1.0]。
        var whitenTeeth: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "whiten_teeth") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "whiten_teeth", value)
            }

        // 去法令纹 强度 取值范围为 [0.0,1.0]。
        var nasolabialFold: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "nasolabial_fold") ?: 0.8f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "nasolabial_fold", value)
            }

        // 亮眼 强度 取值范围为 [0.0,1.0]。
        var brightenEye: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "brighten_eye") ?: 0.8f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "brighten_eye", value)
            }

        // 去眼袋/去黑眼圈 强度 取值范围为 [0.0,1.0]。
        var eyePouch: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "eye_pouch") ?: 0.8f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "eye_pouch", value)
            }

        // --------------------------------------------- 画质 start ----------------------------------------------------
        // 色温 强度 取值范围为 [-1.0,1.0]。
        var temperature: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "temperature") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "temperature", value)
            }

        // 色调 强度 取值范围为 [-1.0,1.0]。
        var hue: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "hue") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "hue", value)
            }

        // 饱和度 强度 取值范围为 [-1.0,1.0]。
        var saturation: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "saturation") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "saturation", value)
            }

        // 亮度 强度 取值范围为 [-1.0,1.0]。
        var brightness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "brightness") ?: 0f
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "brightness", value)
            }

        // ----------------------------------------- 美型 ---------------------------------------------------------------
        // 打开/关闭美型
        var faceShapeEnable: Boolean = false
            get() = parentBeautyEffect?.getVideoEffectBoolParam("face_shape_beauty_option", "enable") ?: false
            set(value) {
                field = value
                // Just set the parameter, don't call addOrUpdateVideoEffect to avoid overriding beauty effect
                parentBeautyEffect?.setVideoEffectBoolParam("face_shape_beauty_option", "enable", value)
                notifyBeautyStateChanged()
            }

        // 美型风格，int -1(无);0(女神);1(男神);2(自然) 会对所有打开的美型部位再增强强度，这样不需要一个个部位set。
        var faceShapeStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("face_shape_beauty_option", "style") ?: 0
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectIntParam("face_shape_beauty_option", "style", value)
            }

        // 美型风格强度，取值范围为 [0,100]。
        var faceShapeIntensity: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("face_shape_beauty_option", "intensity") ?: 0
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectIntParam("face_shape_beauty_option", "intensity", value)
            }

        // 小头 对应修饰力度范围为 [0,100]，缩小整个头。
        var headScale = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_HEADSCALE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_HEADSCALE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 额头/发际线 对应修饰力度范围为 [0,100]，拉低发际线。
        var foreHead = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FOREHEAD)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FOREHEAD, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 瘦脸 对应修饰力度范围为 [0,100]，缩小整个脸庞轮廓。
        var faceContour = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACECONTOUR)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACECONTOUR, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 长脸 对应修饰力度范围为 [-100,100]，垂直方向脸拉伸：正数拉长，负数缩短。
        var faceLength = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACELENGTH)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACELENGTH, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 窄脸 对应修饰力度范围为 [0,100]，水平方向缩窄脸。
        var faceWidth = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACEWIDTH)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACEWIDTH, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 瘦颧骨 对应修饰力度范围为 [0,100]，压缩颧骨突出部位。
        var cheekbone = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHEEKBONE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHEEKBONE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 脸颊/瘦下颌骨 对应修饰力度范围为 [0,100]，下颌线整体内部收缩。
        var cheek = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHEEK)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHEEK, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 下颚(V脸) 对应修饰力度范围为 [0,100]，V脸效果，适合圆脸。
        var mandible = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MANDIBLE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MANDIBLE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 下巴 对应修饰力度范围为 [-100,100]，下巴拉长(正数)与收缩(负数)。
        var chin = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHIN)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_CHIN, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 大眼 对应修饰力度范围为 [0,100]，眼睛整体放大。
        var eyeScale = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYESCALE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYESCALE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眼距 对应修饰力度范围为 [-100,100]，双眼眼距调节, 正值为收窄，负值为拉大。
        var eyeDistance = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEDISTANCE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEDISTANCE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眼上下 对应修饰力度范围为 [-100,100]，双眼上下调节，正值为上移，负值为下移。
        var eyePosition = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEPOSITION)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEPOSITION, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眼睑下至 对应修饰力度范围为 [0,100]，下眼皮向外突出效果。
        var eyeLid = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYELID)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYELID, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眼瞳 对应修饰力度范围为 [0,100]，眼瞳放大效果。
        var eyePupils = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEPUPILS)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEPUPILS, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 内眼角 对应修饰力度范围为 [-100,100]，内眼角的位置。正值为向鼻子收缩，负值为反方向。
        var eyeInnerCorner = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEINNERCORNER)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEINNERCORNER, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 外眼角 对应修饰力度范围为 [-100,100]，外眼角的位置。正值为向眼睛外扩，负值为向眼睛内收缩。
        var eyeOuterCorner = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEOUTERCORNER)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEOUTERCORNER, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 长鼻 对应修饰力度范围为 [-100,100]，长鼻效果。正值为变长，负值为变短。
        var noseLength = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSELENGTH)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSELENGTH, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 瘦鼻 对应修饰力度范围为 [0,100]，瘦鼻效果。
        var noseWidth = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEWIDTH)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEWIDTH, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 鼻翼 对应修饰力度范围为 [0,100]，鼻翼收缩效果。
        var noseWing = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEWING)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEWING, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 山根 对应修饰力度范围为 [0,100]，山根收缩效果（山根为鼻梁顶端，双眼中点位置）。
        var noseRoot = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEROOT)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEROOT, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 鼻梁 对应修饰力度范围为 [0,100]，鼻梁收缩效果。
        var noseBridge = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEBRIDGE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEBRIDGE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 鼻尖 对应修饰力度范围为 [0,100]，鼻尖收缩效果。
        var noseTip = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSETIP)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSETIP, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 鼻综合 对应修饰力度范围为 [-100,100]，鼻整体收缩效果。正值为变小，负值为变大。
        var noseGeneral = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEGENERAL)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_NOSEGENERAL, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 嘴型 对应修饰力度范围为 [-100,100]，嘴巴缩放。正值为变大，负值为变小。
        var mouthScale = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHSCALE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHSCALE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 人中/嘴上下 对应修饰力度范围为 [0,100]，“人中”是嘴的上下位置，一般瘦脸比较大需要人中往上提一些保证五官对称。正值为上移。
        var mouthPosition = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHPOSITION)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHPOSITION, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 微笑 对应修饰力度范围为 [0,100]，嘴角微笑强度。
        var mouthSmile = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHSMILE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHSMILE, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 丰唇 对应修饰力度范围为 [0,100]，丰唇效果。
        var mouthLip = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHLIP)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_MOUTHLIP, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眉毛高低 对应修饰力度范围为 [-100,100]，双眉上下，正值为上移，负值为下移。
        var eyebrowPosition = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEBROWPOSITION)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEBROWPOSITION, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }

        // 眉毛粗细 对应修饰力度范围为 [-100,100]，双眉粗细。正值为变粗，负值为变细。
        var eyebrowThickness = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEBROWTHICKNESS)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEBROWTHICKNESS, value);
                parentRtcEngine?.setFaceShapeAreaOptions(areaOption)
            }
        // =================================== 美颜 end ==========================

        // =================================== 美妆 start ==========================
        // 美妆素材
        var makeupName: String? = null
            set(value) {
                if (field == value) {
                    return
                }
                field = value
                if (value == null) {
                    parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value)
                }
                if (makeupEnable && value != null) {
                    parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value, value
                    )
                }
            }

        /**
         * 美妆强度缓存 Map
         * key: 美妆模板名称 (makeupName)
         * value: 该模板的强度值 [0.0, 1.0f]
         *
         * 用途：记录每个美妆模板的强度值，切换模板时保持用户设置的强度
         * 清空时机：在 unInitBeautySDK() 中清空，确保下次初始化时不会使用旧数据
         */
        internal val makeupIntensityMap: MutableMap<String, Float> = mutableMapOf()

        /**
         * 风格妆强度 取值范围为 [0.0,1.0f]
         *
         * 获取逻辑：
         * 1. 如果没有选择美妆模板，返回 0f
         * 2. 优先从缓存 makeupIntensityMap 中读取该模板的强度值
         * 3. 缓存未命中时，从 parentBeautyEffect 读取并更新缓存
         *
         * 设置逻辑：
         * 1. 更新缓存中当前模板的强度值
         * 2. 同步更新底层效果参数
         */
        var makeupIntensity: Float = 0f
            get() {
                val currentMakeupName = makeupName ?: return 0f

                // 优先从缓存读取
                val cacheIntensity = makeupIntensityMap[currentMakeupName]
                if (cacheIntensity != null) {
                    return cacheIntensity
                }

                // 缓存未命中时，从 parentBeautyEffect 读取并更新缓存
                val strength =
                    parentBeautyEffect?.getVideoEffectFloatParam("style_makeup_option", "styleIntensity") ?: 0f

                // 将读取到的值存入缓存，避免下次重复读取
                makeupIntensityMap[currentMakeupName] = strength
                return strength
            }
            set(value) {
                field = value
                // 更新缓存和底层效果参数
                makeupName?.let { name ->
                    makeupIntensityMap[name] = value
                    parentBeautyEffect?.setVideoEffectFloatParam("style_makeup_option", "styleIntensity", value)
                }
            }

        /**
         * 获取指定美妆模板的强度值
         * 优先从缓存读取，缓存未命中时返回 null（用于区分"用户从未设置过"和"用户设置为 0"）
         *
         * @param templateName 美妆模板名称
         * @return 该模板的强度值，如果缓存中没有则返回 null
         */
        fun getMakeupIntensityForTemplate(templateName: String): Float? {
            return makeupIntensityMap[templateName]
        }

        // 风格妆滤镜 强度 取值范围为 [0.0,1.0f]。 风格妆滤镜强度和滤镜模板中滤镜强度会有冲突
        var makeupFilterStrength: Float = 0f
            get() {
                val strength =
                    parentBeautyEffect?.getVideoEffectFloatParam("style_makeup_option", "filterStrength") ?: 0f
                return strength
            }
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("style_makeup_option", "filterStrength", value)
            }
        // =================================== 美妆 end ==========================

        // =================================== 滤镜 start ==========================
        // 滤镜模板
        var filterName: String? = null
            set(value) {
                if (field == value) {
                    return
                }
                field = value
                if (value == null) {
                    parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value)
                }
                if (filterEnable && value != null) {
                    parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value, value
                    )
                }
            }


        /**
         * 滤镜强度缓存 Map
         * key: 滤镜模板名称 (filterName)
         * value: 该模板的强度值 [0.0, 1.0f]
         *
         * 用途：记录每个滤镜模板的强度值，切换模板时保持用户设置的强度
         * 清空时机：在 unInitBeautySDK() 中清空，确保下次初始化时不会使用旧数据
         */
        internal val filterStrengthMap: MutableMap<String, Float> = mutableMapOf()

        // 滤镜 强度 取值范围为 [0.0,1.0f]
        var filterStrength: Float = 0f
            get() {
                val currentFilterName = filterName ?: return 0f

                // 优先从缓存读取
                val cacheIntensity = filterStrengthMap[currentFilterName]
                if (cacheIntensity != null) {
                    return cacheIntensity
                }

                // 缓存未命中时，从 parentBeautyEffect 读取并更新缓存
                val strength =
                    parentBeautyEffect?.getVideoEffectFloatParam("filter_effect_option", "strength") ?: 0f
                Log.d("filterStrength", "filterStrength $strength")

                // 将读取到的值存入缓存，避免下次重复读取
                filterStrengthMap[currentFilterName] = strength
                return strength
            }
            set(value) {
                field = value
                // 更新缓存和底层效果参数
                filterName?.let { name ->
                    filterStrengthMap[name] = value
                    parentBeautyEffect?.setVideoEffectFloatParam("filter_effect_option", "strength", value)
                }
            }

        /**
         * 获取指定滤镜模板的强度值
         * 优先从缓存读取，缓存未命中时返回 null（用于区分"用户从未设置过"和"用户设置为 0"）
         *
         * @param templateName 滤镜模板名称
         * @return 该模板的强度值，如果缓存中没有则返回 null
         */
        fun getFilterStrengthForTemplate(templateName: String): Float? {
            return filterStrengthMap[templateName]
        }
        // =================================== 滤镜 end ==========================

        // =================================== 贴纸 start ==========================
        // 贴纸素材
        var stickerName: String? = null
            set(value) {
                if (field == value) {
                    return
                }
                field = value
                if (value == null) {
                    parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value)
                }
                if (stickerEnable && value != null) {
                    parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value, value
                    )
                }
            }

        // 贴纸 强度 取值范围为 [0.0,1.0f]，贴纸的透明度。一般贴纸设计怎样就怎样展示，无特别需求请不要调参
        var stickerStrength: Float = 0f
            get() {
                val strength = parentBeautyEffect?.getVideoEffectFloatParam("sticker_effect_option", "strength") ?: 0f
                return strength
            }
            set(value) {
                field = value
                parentBeautyEffect?.setVideoEffectFloatParam("sticker_effect_option", "strength", value)
            }
        // =================================== 贴纸 end ==========================

        // 重置美肤参数
        internal fun resetBeauty(nodeId: IVideoEffectObject.VIDEO_EFFECT_NODE_ID = IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY) {
            parentBeautyEffect?.performVideoEffectAction(nodeId.value, IVideoEffectObject.VIDEO_EFFECT_ACTION.RESET)
        }

        // 保存美颜节点
        internal fun saveBeauty(nodeId: IVideoEffectObject.VIDEO_EFFECT_NODE_ID = IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY) {
            parentBeautyEffect?.performVideoEffectAction(nodeId.value, IVideoEffectObject.VIDEO_EFFECT_ACTION.SAVE)
        }
    }
}
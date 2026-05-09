package cn.shengwang.beauty.core

import android.util.Log
import io.agora.rtc2.Constants
import io.agora.rtc2.ExtensionContext
import io.agora.rtc2.IVideoEffectObject
import io.agora.rtc2.RtcEngine
import io.agora.rtc2.video.FaceShapeAreaOptions
import kotlin.math.abs
import org.json.JSONException
import org.json.JSONObject



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
    private const val BEAUTY_PROVIDER_NAME = "agora_video_filters_clear_vision"
    private const val BEAUTY_EXTENSION_NAME = "clear_vision"
    private const val BEAUTY_EVENT_KEY = "beauty"
    private val beautyErrorCodeHints: Map<Int, String> = mapOf(
        1700 to "ERR_VIDEOEFFECT_ASSET_INVALID: beauty 资源包无效或损坏",
        1701 to "ERR_VIDEOEFFECT_SAVE_FAILED: beauty 配置保存失败",
        1702 to "ERR_VIDEOEFFECT_ENGINE_INVALID: beauty 引擎状态无效",
        1704 to "ERR_VIDEOEFFECT_NODE_NOT_ACTIVE: beauty 节点未激活",
        1705 to "ERR_VIDEOEFFECT_INVALID_PARAM: beauty 参数无效",
        1706 to "ERR_VIDEOEFFECT_NOT_SUPPORTED: 当前设备不支持 beauty",
        1707 to "ERR_VIDEOEFFECT_INVALID_BUNDLE_PATH: beauty 素材路径无效"
    )
    private val commonErrorCodeHints: Map<Int, String> = mapOf(
        2 to "ERR_INVALID_ARGUMENT: 传入参数无效",
        3 to "ERR_NOT_READY: SDK 当前状态未就绪",
        4 to "ERR_NOT_SUPPORTED: 当前设备或场景不支持该能力",
        7 to "ERR_NOT_INITIALIZED: SDK 尚未初始化"
    )
    private var rtcEngine: RtcEngine? = null
    private var beautyEffect: IVideoEffectObject? = null

    private var beautyEnable = false
    private var filterEnable = false
    private var makeupEnable = false
    private var stickerEnable = false

    // 状态监听器
    var beautyStateListener: (() -> Unit)? = null
    var beautyEventListener: ((String, String) -> Unit)? = null

    /**
     * 指定美颜 UI 的显示语言，覆盖系统语言。
     * 设置为 BCP 47 语言标签（如 "ja"、"ko"、"fr"、"ar"），在初始化 ShengwangBeautyView 之前设置。
     * 设置为 null（默认）则跟随系统语言。
     *
     * 示例：
     *   ShengwangBeautyManager.forcedLanguage = "ja"  // 强制日语
     *   ShengwangBeautyManager.forcedLanguage = null  // 跟随系统语言（默认）
     */
    var forcedLanguage: String? = null

    /**
     * 通知监听器状态已变化
     */
    private fun notifyBeautyStateChanged() {
        beautyStateListener?.invoke()
    }

    /**
     * 处理扩展事件回调，仅转发 beauty 扩展发出的 "beauty" 事件。
     * 注意：该回调线程由 RTC SDK 内部线程决定，若需更新 UI 请切回主线程。
     */
    fun handleExtensionEventWithContext(extContext: ExtensionContext, key: String?, value: String?) {
        if (extContext.providerName != BEAUTY_PROVIDER_NAME ||
            extContext.extensionName != BEAUTY_EXTENSION_NAME ||
            key != BEAUTY_EVENT_KEY ||
            value.isNullOrEmpty()
        ) {
            return
        }
        Log.d(
            TAG,
            "Beauty extension event received: key=$key, value=$value, uid=${extContext.uid}, isValid=${extContext.isValid}"
        )
        beautyEventListener?.invoke(key, value)
    }

    private fun printLog(errCode: Int) {
        if (errCode == Constants.ERR_OK) {
            return
        }
        val normalizedErrCode = abs(errCode)
        val errorMsg = RtcEngine.getErrorDescription(errCode)
        val hintText = beautyErrorCodeHints[normalizedErrCode]
            ?: commonErrorCodeHints[normalizedErrCode]
        val hint = hintText?.let { " ($it)" } ?: ""
        Log.e(
            TAG,
            "VideoEffect API failed: errorCode=$errCode, normalizedErrorCode=$normalizedErrCode, errorMsg=$errorMsg$hint"
        )
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

        // only in debug mode
//        enableInnerLog(true)

        // Enable beauty by default
        enable(true)

        // apply default value
        applyDefaultValue()

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
            val ret = rtcEngine?.destroyVideoEffectObject(effect)
            if (ret != null) {
                printLog(ret)
            }
            }
            
            val ret = rtcEngine?.enableExtension(
                "agora_video_filters_clear_vision",
                "clear_vision",
                false,
                Constants.MediaSourceType.PRIMARY_CAMERA_SOURCE
            )
            if (ret != null) {
                printLog(ret)
            }
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

    private fun enableInnerLog(enable: Boolean) {
        val debugObj = JSONObject()
        debugObj.put("logfile_enable", enable)
        rtcEngine?.setExtensionProperty(
            "agora_video_filters_clear_vision", "clear_vision",
            "debug_param", debugObj.toString()
        )
    }

    private fun applyDefaultValue() {
        beautyConfig.smoothness = 0.65f
        beautyConfig.whitenStrength = 0.5f
        beautyConfig.sharpness = 0.15f
        beautyConfig.faceContour = 50
        beautyConfig.faceWidth = 10
        beautyConfig.cheekbone = 15
        beautyConfig.cheek = 30
        beautyConfig.chin = 65
        beautyConfig.nasolabialFold = 0.3f
        beautyConfig.eyeScale = 30
        beautyConfig.brightenEye = 0.3f
        beautyConfig.noseWidth = 70
        beautyConfig.noseLength = 50
        beautyConfig.mouthScale = 65
        beautyConfig.whitenTeeth = 0.3f
        beautyConfig.contrastStrength = 0.15f
    }

    private fun enableBeauty(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == beautyEnable) return
        if (enable) {
            if (beautyConfig.beautyName != null) {
                val ret = effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value, beautyConfig.beautyName
                )
                printLog(ret)
            }
            beautyConfig.beautyEnable = true
            beautyConfig.faceShapeEnable = true
        } else {
            val ret = effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value)
            printLog(ret)
        }
        this.beautyEnable = enable
    }

    private fun enableFilter(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == filterEnable) return
        if (enable) {
            if (beautyConfig.filterName != null) {
                val ret = effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value, beautyConfig.filterName
                )
                printLog(ret)
            }
        } else {
            val ret = effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value)
            printLog(ret)
        }
        this.filterEnable = enable
    }

    private fun enableMakeup(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == makeupEnable) return
        if (enable) {
            if (beautyConfig.makeupName != null) {
                val ret = effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value, beautyConfig.makeupName
                )
                printLog(ret)
            }
        } else {
            val ret = effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value)
            printLog(ret)
        }
        this.makeupEnable = enable
    }

    private fun enableSticker(enable: Boolean) {
        val effect = beautyEffect ?: return
        if (enable == stickerEnable) return
        if (enable) {
            if (beautyConfig.stickerName != null) {
                val ret = effect.addOrUpdateVideoEffect(
                    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value, beautyConfig.stickerName
                )
                printLog(ret)
            }
        } else {
            val ret = effect.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value)
            printLog(ret)
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
                val ret = parentBeautyEffect?.addOrUpdateVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.value, value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 打开/关闭基础美颜+美肤+画质
        var beautyEnable: Boolean = false
            get() = parentBeautyEffect?.getVideoEffectBoolParam("beauty_effect_option", "enable") ?: false
            set(value) {
                field = value
                // Just set the parameter, don't call addOrUpdateVideoEffect to avoid overriding beauty effect
                val ret = parentBeautyEffect?.setVideoEffectBoolParam("beauty_effect_option", "enable", value)
                if (ret != null) {
                    printLog(ret)
                }
                notifyBeautyStateChanged()
            }

        // 磨皮 强度，取值范围为 [0.0,1.0]。
        var smoothness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "smoothness") ?: 0.0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "smoothness", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 美白 强度，取值范围为 [0.0,1.0]。
        var whitenStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "lightness") ?: 0.0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "lightness", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 美白 LUT 路径（自定义美白滤镜的相对路径）
        // 声网默认素材包中：冷白："../resource/whiten/lengbai.png"，粉白："../resource/whiten/fenbai.png"，超白："../resource/whiten/chaobai.png"，默认自然白：""
        var whitenLut: String = ""
            set(value) {
                if (field == value) return
                field = value
                val ret = parentBeautyEffect?.setVideoEffectStringParam("beauty_effect_option", "whiten_lut_path", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 红润 强度，取值范围为 [0.0,1.0]。
        var redness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "redness") ?: 0.3f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "redness", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 锐化 强度，取值范围为 [0.0,1.0]。
        var sharpness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "sharpness") ?: 0.6f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "sharpness", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 清晰度 强度，取值范围为 [-1.0,1.0]。
        var contrastStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "contrast_strength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "contrast_strength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        var contrastFactor: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "contrast_factor") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "contrast_factor", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 白牙 强度 取值范围为 [0.0,1.0]。
        var whitenTeeth: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "whiten_teeth") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "whiten_teeth", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 去法令纹 强度 取值范围为 [0.0,1.0]。
        var nasolabialFold: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "nasolabial_fold") ?: 0.8f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "nasolabial_fold", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 亮眼 强度 取值范围为 [0.0,1.0]。
        var brightenEye: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "brighten_eye") ?: 0.8f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "brighten_eye", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 去眼袋/去黑眼圈 强度 取值范围为 [0.0,1.0]。
        var eyePouch: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("face_buffing_option", "eye_pouch") ?: 0.8f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("face_buffing_option", "eye_pouch", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // --------------------------------------------- 画质 start ----------------------------------------------------
        // 画质总开关（关闭时将所有画质参数重置为0）
        var qualityEnable: Boolean = false
            set(value) {
                if (field == value) return
                field = value
                if (!value) {
                    hue = 0f
                    saturation = 0f
                    brightness = 0f
                    temperature = 0f
                    contrastFactor = 0f
                }
                notifyBeautyStateChanged()
            }

        // 色温 强度 取值范围为 [-1.0,1.0]。
        var temperature: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "temperature") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "temperature", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 色调 强度 取值范围为 [-1.0,1.0]。
        var hue: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "hue") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "hue", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 饱和度 强度 取值范围为 [-1.0,1.0]。
        var saturation: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "saturation") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "saturation", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 亮度 强度 取值范围为 [-1.0,1.0]。
        var brightness: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("beauty_effect_option", "brightness") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("beauty_effect_option", "brightness", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // ----------------------------------------- 美型 ---------------------------------------------------------------
        // 打开/关闭美型
        var faceShapeEnable: Boolean = false
            get() = parentBeautyEffect?.getVideoEffectBoolParam("face_shape_beauty_option", "enable") ?: false
            set(value) {
                field = value
                // Just set the parameter, don't call addOrUpdateVideoEffect to avoid overriding beauty effect
                val ret = parentBeautyEffect?.setVideoEffectBoolParam("face_shape_beauty_option", "enable", value)
                if (ret != null) {
                    printLog(ret)
                }
                notifyBeautyStateChanged()
            }

        // 美型风格，int -1(无);0(女神);1(男神);2(自然) 会对所有打开的美型部位再增强强度，这样不需要一个个部位set。
        var faceShapeStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("face_shape_beauty_option", "style") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("face_shape_beauty_option", "style", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 美型风格强度，取值范围为 [0,100]。
        var faceShapeIntensity: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("face_shape_beauty_option", "intensity") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("face_shape_beauty_option", "intensity", value)
                if (ret != null) {
                    printLog(ret)
                }
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

        // 长脸 对应修饰力度范围为 [0,100]，垂直方向脸拉伸：正数拉长，负数缩短。
        var faceShort = 0
            get() = -(parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACELENGTH)?.shapeIntensity ?: 0)
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACELENGTH, -value);
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

        var faceSmall = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACESMALL)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_FACESMALL, value);
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

        var eyeAngle = 0
            get() = parentRtcEngine?.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEANGLE)?.shapeIntensity
                ?: 0
            set(value) {
                field = value
                val areaOption = FaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_EYEANGLE, value);
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
                    val ret = parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value)
                    if (ret != null) {
                        printLog(ret)
                    }
                }
                if (makeupEnable && value != null) {
                    val ret = parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.value, value
                    )
                    if (ret != null) {
                        printLog(ret)
                    }
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
                    val ret = parentBeautyEffect?.setVideoEffectFloatParam("style_makeup_option", "styleIntensity", value)
                    if (ret != null) {
                        printLog(ret)
                    }
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
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("style_makeup_option", "filterStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // =================================== 自定义美妆 start ==========================

        // 自定义美妆总开关
        var customMakeupEnable: Boolean = false
            get() = parentBeautyEffect?.getVideoEffectBoolParam("makeup_options", "enable_mu") ?: false
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectBoolParam("makeup_options", "enable_mu", value)
                if (ret != null) {
                    printLog(ret)
                }
                notifyBeautyStateChanged()
            }

        // 口红样式
        var customLipstickStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "lipStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "lipStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 口红颜色
        var customLipstickColor: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "lipColor") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "lipColor", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 口红强度 取值范围为 [0.0, 1.0]
        var customLipstickStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "lipStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "lipStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 腮红样式
        var customBlushStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "blushStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "blushStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 腮红强度 取值范围为 [0.0, 1.0]
        var customBlushStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "blushStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "blushStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 修容样式
        var customFacialStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "facialStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "facialStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 修容强度 取值范围为 [0.0, 1.0]
        var customFacialStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "facialStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "facialStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 眼影样式
        var customEyeshadowStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "shadowStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "shadowStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 眼影强度 取值范围为 [0.0, 1.0]
        var customEyeshadowStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "shadowStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "shadowStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 修眉样式
        var customEyebrowStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "browStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "browStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 修眉强度 取值范围为 [0.0, 1.0]
        var customEyebrowStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "browStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "browStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 美瞳样式
        var customPupilStyle: Int = 0
            get() = parentBeautyEffect?.getVideoEffectIntParam("makeup_options", "pupilStyle") ?: 0
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectIntParam("makeup_options", "pupilStyle", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // 美瞳强度 取值范围为 [0.0, 1.0]
        var customPupilStrength: Float = 0f
            get() = parentBeautyEffect?.getVideoEffectFloatParam("makeup_options", "pupilStrength") ?: 0f
            set(value) {
                field = value
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("makeup_options", "pupilStrength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }

        // =================================== 自定义美妆 end ==========================

        // =================================== 滤镜 start ==========================
        // 滤镜模板
        var filterName: String? = null
            set(value) {
                if (field == value) {
                    return
                }
                field = value
                if (value == null) {
                    val ret = parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value)
                    if (ret != null) {
                        printLog(ret)
                    }
                }
                if (filterEnable && value != null) {
                    val ret = parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.FILTER.value, value
                    )
                    if (ret != null) {
                        printLog(ret)
                    }
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
                    val ret = parentBeautyEffect?.setVideoEffectFloatParam("filter_effect_option", "strength", value)
                    if (ret != null) {
                        printLog(ret)
                    }
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
                    val ret = parentBeautyEffect?.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value)
                    if (ret != null) {
                        printLog(ret)
                    }
                }
                if (stickerEnable && value != null) {
                    val ret = parentBeautyEffect?.addOrUpdateVideoEffect(
                        IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.value, value
                    )
                    if (ret != null) {
                        printLog(ret)
                    }
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
                val ret = parentBeautyEffect?.setVideoEffectFloatParam("sticker_effect_option", "strength", value)
                if (ret != null) {
                    printLog(ret)
                }
            }
        // =================================== 贴纸 end ==========================

        // 重置美颜节点
        internal fun resetBeauty(nodeId: IVideoEffectObject.VIDEO_EFFECT_NODE_ID = IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY) {
            // 选择1：用SDK的接口重置
            val ret = parentBeautyEffect?.performVideoEffectAction(nodeId.value, IVideoEffectObject.VIDEO_EFFECT_ACTION.RESET)
            if (ret != null) {
                printLog(ret)
            }
            // 选择2：代码默认值重置
            applyDefaultValue()
        }

        // 保存美颜节点
        internal fun saveBeauty(nodeId: IVideoEffectObject.VIDEO_EFFECT_NODE_ID = IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY) {
            // 选择1：用SDK的接口重置
            val ret = parentBeautyEffect?.performVideoEffectAction(nodeId.value, IVideoEffectObject.VIDEO_EFFECT_ACTION.SAVE)
            if (ret != null) {
                printLog(ret)
            }
            // 选择2：app自己落盘
            // ...
        }
    }
}

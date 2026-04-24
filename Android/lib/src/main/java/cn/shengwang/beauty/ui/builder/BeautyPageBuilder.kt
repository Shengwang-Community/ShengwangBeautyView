package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 美颜模块页面构建器
 * 负责构建美颜（美肤+美型+画质）模块的页面信息
 *
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class BeautyPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig,
    private val refreshPageList: () -> Unit
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val beautyItems = mutableListOf<BeautyItemInfo>()

        // 基础功能项（始终显示）
        // 1. 开关项（选中表示开启）
        val isBeautyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
        beautyItems.add(
            BeautyItemInfo(
                name = if (isBeautyEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
                icon = if (isBeautyEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
                showSlider = false,
                type = BeautyItemType.TOGGLE,
                onItemClick = { itemInfo ->
                    // 切换美颜和美型状态
                    val isCurrentlyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
                    val newEnabledState = !isCurrentlyEnabled

                    if (isCurrentlyEnabled) {
                        // 当前是开启状态（选中），点击后关闭（取消选中）
                        beautyConfig.beautyEnable = false
                        beautyConfig.faceShapeEnable = false
                    } else {
                        // 当前是关闭状态（未选中），点击后开启（选中）
                        beautyConfig.beautyEnable = true
                        beautyConfig.faceShapeEnable = true
                    }
                    // 更新 itemInfo 的属性，View 层会通过 notifyItemChanged 触发 UI 更新
                    itemInfo.name =
                        if (newEnabledState) R.string.beauty_effect_enable else R.string.beauty_effect_disable
                    itemInfo.icon =
                        if (newEnabledState) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off
                    // 刷新整个页面列表以更新开关状态和其他参数值
                    refreshPageList.invoke()
                }
            )
        )

        // 2. 重置按钮
        beautyItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_reset,
                R.drawable.beauty_ic_effect_reset,
                showSlider = false,
                type = BeautyItemType.RESET,
                onItemClick = {
                    // 调用重置功能
                    beautyConfig.resetBeauty()
                    // 刷新整个页面列表以更新开关状态和其他参数值
                    refreshPageList.invoke()
                }
            )
        )

        // 美颜参数（美肤+美型混排，按指定顺序）
        addBeautyItems(beautyItems)

        // 画质参数（已全部注释，当前不显示）
        // addQualityItems(beautyItems)

        return BeautyPageInfo(
            R.string.beauty_group_beauty,
            beautyItems,
            type = BeautyModule.BEAUTY
        )
    }

    /**
     * 添加美颜参数（美肤+美型混排，严格按指定顺序）
     * 顺序：美白、磨皮、红润、瘦脸、V脸、窄脸、大眼、眼距、亮眼、瘦颧骨、瘦鼻、长鼻、嘴形、下巴、瘦下颌骨、黑眼圈、法令纹
     */
    private fun addBeautyItems(items: MutableList<BeautyItemInfo>) {
        // 1. 美白
        addSkinBeautyItem(items, R.string.beauty_effect_lightness, R.drawable.beauty_ic_effect_lightness, beautyConfig.whitenNatural, isSelected = beautyConfig.beautyEnable) { value -> beautyConfig.whitenNatural = value }
        // 2. 磨皮
        addSkinBeautyItem(items, R.string.beauty_effect_smoothness, R.drawable.beauty_ic_effect_smoothness, beautyConfig.smoothness) { value -> beautyConfig.smoothness = value }
        // 3. 红润
        addSkinBeautyItem(items, R.string.beauty_effect_redness, R.drawable.beauty_ic_effect_redness, beautyConfig.redness) { value -> beautyConfig.redness = value }
        // 4. 瘦脸
        addFaceShapeItem(items, R.string.beauty_face_shape_face_contour, R.drawable.beauty_ic_face_shape_face_contour, beautyConfig.faceContour) { value -> beautyConfig.faceContour = value }
        // 5. V脸
        addFaceShapeItem(items, R.string.beauty_face_shape_mandible, R.drawable.beauty_ic_face_shape_mandible, beautyConfig.mandible) { value -> beautyConfig.mandible = value }
        // 6. 窄脸
        addFaceShapeItem(items, R.string.beauty_face_shape_face_width, R.drawable.beauty_ic_face_shape_face_width, beautyConfig.faceWidth) { value -> beautyConfig.faceWidth = value }
        // 7. 大眼
        addFaceShapeItem(items, R.string.beauty_face_shape_eye_scale, R.drawable.beauty_ic_face_shape_eye_scale, beautyConfig.eyeScale) { value -> beautyConfig.eyeScale = value }
        // 8. 眼距
        addFaceShapeItem(items, R.string.beauty_face_shape_eye_distance, R.drawable.beauty_ic_face_shape_eye_distance, beautyConfig.eyeDistance, valueRange = -100f..100f) { value -> beautyConfig.eyeDistance = value }
        // 9. 亮眼
        addSkinBeautyItem(items, R.string.beauty_effect_brighten_eye, R.drawable.beauty_ic_effect_brighten_eye, beautyConfig.brightenEye) { value -> beautyConfig.brightenEye = value }
        // 10. 瘦颧骨
        addFaceShapeItem(items, R.string.beauty_face_shape_cheekbone, R.drawable.beauty_ic_face_shape_cheekbone, beautyConfig.cheekbone) { value -> beautyConfig.cheekbone = value }
        // 11. 瘦鼻
        addFaceShapeItem(items, R.string.beauty_face_shape_nose_width, R.drawable.beauty_ic_face_shape_nose_width, beautyConfig.noseWidth) { value -> beautyConfig.noseWidth = value }
        // 12. 长鼻
        addFaceShapeItem(items, R.string.beauty_face_shape_nose_length, R.drawable.beauty_ic_face_shape_nose_length, beautyConfig.noseLength, valueRange = -100f..100f) { value -> beautyConfig.noseLength = value }
        // 13. 嘴形
        addFaceShapeItem(items, R.string.beauty_face_shape_mouth_scale, R.drawable.beauty_ic_face_shape_mouth_scale, beautyConfig.mouthScale, valueRange = -100f..100f) { value -> beautyConfig.mouthScale = value }
        // 14. 下巴
        addFaceShapeItem(items, R.string.beauty_face_shape_chin, R.drawable.beauty_ic_face_shape_chin, beautyConfig.chin, valueRange = -100f..100f) { value -> beautyConfig.chin = value }
        // 15. 瘦下颌骨
        addFaceShapeItem(items, R.string.beauty_face_shape_cheek, R.drawable.beauty_ic_face_shape_cheek, beautyConfig.cheek) { value -> beautyConfig.cheek = value }
        // 16. 黑眼圈
        addSkinBeautyItem(items, R.string.beauty_effect_eye_pouch, R.drawable.beauty_ic_effect_eye_pouch, beautyConfig.eyePouch) { value -> beautyConfig.eyePouch = value }
        // 17. 法令纹
        addSkinBeautyItem(items, R.string.beauty_effect_nasolabial_fold, R.drawable.beauty_ic_effect_nasolabial_fold, beautyConfig.nasolabialFold) { value -> beautyConfig.nasolabialFold = value }

    }
    /**
     * UI 显示换算规则：
     * - SDK 值范围 0.0~1.0 → UI 显示 0~100（整数）
     * - SDK 值范围 -1.0~1.0 → UI 显示 -50~50（整数）
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值（SDK 原始值）
     * @param isSelected 是否选中（默认false）
     * @param valueRange SDK 值范围（默认0.0f..1.0f）
     * @param onValueChanged 值变化回调（接收 SDK 原始值）
     */
    private fun addSkinBeautyItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Float,
        isSelected: Boolean = false,
        valueRange: ClosedFloatingPointRange<Float> = 0.0f..1.0f,
        onValueChanged: (Float) -> Unit
    ) {
        val isBipolar = valueRange.start < 0f
        // UI 显示范围和换算
        val uiRange = if (isBipolar) -50f..50f else 0f..100f
        val uiValue = if (isBipolar) {
            currentValue * 50f  // -1.0~1.0 → -50~50
        } else {
            currentValue * 100f // 0.0~1.0 → 0~100
        }
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                uiValue,
                isSelected = isSelected,
                valueRange = uiRange,
                onValueChanged = { uiVal ->
                    val sdkValue = if (isBipolar) uiVal / 50f else uiVal / 100f
                    onValueChanged(sdkValue)
                }
            )
        )
    }

    /**
     * 添加单个美型参数项
     *
     * UI 显示换算规则：
     * - SDK 值范围 0~100 → UI 显示 0~100（整数，不变）
     * - SDK 值范围 -100~100 → UI 显示 -50~50（整数），回调时 ×2 还原
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值（Int类型，SDK 原始值）
     * @param valueRange SDK 值范围（默认0f..100f）
     * @param onValueChanged 值变化回调（接收 SDK 原始 Int 值）
     */
    private fun addFaceShapeItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Int,
        valueRange: ClosedFloatingPointRange<Float> = 0f..100f,
        onValueChanged: (Int) -> Unit
    ) {
        val isBipolar = valueRange.start < 0f
        val uiRange = if (isBipolar) -50f..50f else valueRange
        val uiValue = if (isBipolar) currentValue / 2f else currentValue.toFloat()
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                uiValue,
                valueRange = uiRange,
                onValueChanged = { value ->
                    val sdkValue = if (isBipolar) (value * 2f).toInt() else value.toInt()
                    onValueChanged(sdkValue)
                }
            )
        )
    }

    /**
     * 添加画质参数
     * 顺序：色调、色温、饱和度、亮度
     */
    private fun addQualityItems(items: MutableList<BeautyItemInfo>) {
        // 色温
        addQualityItem(
            items,
            R.string.beauty_effect_temperature,
            R.drawable.beauty_ic_effect_temperature,
            beautyConfig.temperature
        ) { value ->
            beautyConfig.temperature = value
        }
        // 色调
        addQualityItem(
            items,
            R.string.beauty_effect_hue,
            R.drawable.beauty_ic_effect_hue,
            beautyConfig.hue
        ) { value ->
            beautyConfig.hue = value
        }
        // 饱和度
        addQualityItem(
            items,
            R.string.beauty_effect_saturation,
            R.drawable.beauty_ic_effect_saturation,
            beautyConfig.saturation
        ) { value ->
            beautyConfig.saturation = value
        }
        // 亮度
        addQualityItem(
            items,
            R.string.beauty_effect_brightness,
            R.drawable.beauty_ic_effect_brightness,
            beautyConfig.brightness
        ) { value ->
            beautyConfig.brightness = value
        }
    }

    /**
     * 添加单个画质参数项
     *
     * UI 显示换算规则：SDK 值范围 -1.0~1.0 → UI 显示 -50~50（整数）
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值（SDK 原始值）
     * @param onValueChanged 值变化回调（接收 SDK 原始值）
     */
    private fun addQualityItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Float,
        onValueChanged: (Float) -> Unit
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                currentValue * 50f,  // -1.0~1.0 → -50~50
                valueRange = -50f..50f,
                onValueChanged = { uiVal ->
                    onValueChanged(uiVal / 50f)  // -50~50 → -1.0~1.0
                }
            )
        )
    }
}
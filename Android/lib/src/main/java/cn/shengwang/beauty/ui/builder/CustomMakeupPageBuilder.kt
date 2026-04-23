package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 自定义美妆模块页面构建器
 * 负责构建自定义美妆模块的页面信息，采用二级菜单结构：
 * - 一级：分类入口（口红、腮红、修容、眼影、修眉、美瞳）
 * - 二级：每个分类下的具体选项
 *
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class CustomMakeupPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val items = mutableListOf<BeautyItemInfo>()

        // 开关项：控制整个自定义美妆的开启/关闭
        val isEnabled = beautyConfig.customMakeupEnable
        items.add(
            BeautyItemInfo(
                name = if (isEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
                icon = if (isEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
                isSelected = isEnabled,
                showSlider = false,
                type = BeautyItemType.TOGGLE,
                onItemClick = {
                    beautyConfig.customMakeupEnable = !beautyConfig.customMakeupEnable
                }
            )
        )

        items.add(buildCategoryItem(R.string.beauty_custom_makeup_lipstick, buildLipstickItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_blush, buildBlushItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_contour, buildContourItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_eyeshadow, buildEyeshadowItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_eyebrow, buildEyebrowItems()))

        return BeautyPageInfo(
            R.string.beauty_group_custom_makeup,
            items,
            type = BeautyModule.STYLE_MAKEUP
        )
    }

    // ==================== 一级分类入口 ====================

    private fun buildCategoryItem(
        nameRes: Int,
        subItems: List<BeautyItemInfo>
    ): BeautyItemInfo = BeautyItemInfo(
        name = nameRes,
        icon = R.drawable.beauty_ic_makeup_category,
        showSlider = false,
        type = BeautyItemType.SUB_MENU,
        subItems = subItems
    )

    // ==================== 二级子项构建辅助方法 ====================

    private fun buildSubLipstickItem(nameRes: Int, iconRes: Int, style: Int, color: Int) =
        BeautyItemInfo(
            name = nameRes,
            icon = iconRes,
            value = beautyConfig.customLipstickStrength,
            valueRange = 0f..1.0f,
            itemStyle = style,
            itemColor = color,
            onValueChanged = { value ->
                beautyConfig.customLipstickStrength = value
            },
            onItemClick = { itemInfo ->
                beautyConfig.makeupName = ""
                beautyConfig.customLipstickStyle = itemInfo.itemStyle
                beautyConfig.customLipstickColor = itemInfo.itemColor
                // 所有style共享强度，防止UI跳变
                itemInfo.value = beautyConfig.customLipstickStrength
            }
        )

    private fun buildSubBlushItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes,
            icon = iconRes,
            value = beautyConfig.customBlushStrength,
            valueRange = 0f..1.0f,
            itemStyle = style,
            onValueChanged = { value ->
                beautyConfig.customBlushStrength = value
            },
            onItemClick = { itemInfo ->
                beautyConfig.makeupName = ""
                beautyConfig.customBlushStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customBlushStrength
            }
        )

    private fun buildSubFacialItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes,
            icon = iconRes,
            value = beautyConfig.customFacialStrength,
            valueRange = 0f..1.0f,
            itemStyle = style,
            onValueChanged = { value ->
                beautyConfig.customFacialStrength = value
            },
            onItemClick = { itemInfo ->
                beautyConfig.makeupName = ""
                beautyConfig.customFacialStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customFacialStrength
            }
        )

    private fun buildSubShadowItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes,
            icon = iconRes,
            value = beautyConfig.customEyeshadowStrength,
            valueRange = 0f..1.0f,
            itemStyle = style,
            onValueChanged = { value ->
                beautyConfig.customEyeshadowStrength = value
            },
            onItemClick = { itemInfo ->
                beautyConfig.makeupName = ""
                beautyConfig.customEyeshadowStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customEyeshadowStrength
            }
        )

    private fun buildSubEyebrowItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes,
            icon = iconRes,
            value = beautyConfig.customEyebrowStrength,
            valueRange = 0f..1.0f,
            itemStyle = style,
            onValueChanged = { value ->
                beautyConfig.customEyebrowStrength = value
            },
            onItemClick = { itemInfo ->
                beautyConfig.makeupName = ""
                beautyConfig.customEyebrowStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customEyebrowStrength
            }
        )

    // ==================== 各分类子项列表 ====================

    private fun buildLipstickItems() = listOf(
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_vintage_red,    R.drawable.beauty_ic_makeup_lipstick_vintage_red,    style = 1, color = 2),  // 复古红
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_girl_pink,       R.drawable.beauty_ic_makeup_lipstick_girl_pink,       style = 1, color = 5),  // 少女粉
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_vitality_orange, R.drawable.beauty_ic_makeup_lipstick_vitality_orange, style = 1, color = 9),  // 元气橘
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_grapefruit,      R.drawable.beauty_ic_makeup_lipstick_grapefruit,      style = 1, color = 8),  // 西柚色
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_watermelon_red,  R.drawable.beauty_ic_makeup_lipstick_watermelon_red,  style = 1, color = 7),  // 西瓜红
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_velvet_red,      R.drawable.beauty_ic_makeup_lipstick_velvet_red,      style = 1, color = 6),  // 丝绒红
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_dirty_orange,    R.drawable.beauty_ic_makeup_lipstick_dirty_orange,    style = 1, color = 10), // 脏橘色
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_plum,            R.drawable.beauty_ic_makeup_lipstick_plum,            style = 1, color = 3),  // 梅子色
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_bean_paste_pink, R.drawable.beauty_ic_makeup_lipstick_bean_paste_pink, style = 1, color = 1)   // 豆沙粉
    )

    private fun buildBlushItems() = listOf(
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_tipsy,        R.drawable.beauty_ic_makeup_blush_tipsy,        style = 10), // 微醺
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_daily,        R.drawable.beauty_ic_makeup_blush_daily,        style = 7),  // 日常
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_peach,        R.drawable.beauty_ic_makeup_blush_peach,        style = 5),  // 蜜桃
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_sweet_orange, R.drawable.beauty_ic_makeup_blush_sweet_orange, style = 9),  // 甜橙
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_playful,      R.drawable.beauty_ic_makeup_blush_playful,      style = 6),  // 俏皮
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_scheming,     R.drawable.beauty_ic_makeup_blush_scheming,     style = 11), // 心机
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_sunburn,      R.drawable.beauty_ic_makeup_blush_sunburn,      style = 8)   // 晒伤
    )

    private fun buildContourItems() = listOf(
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_01, R.drawable.beauty_ic_makeup_contour_01, style = 1) // 修容01
    )

    private fun buildEyeshadowItems() = listOf(
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_sunset_red,     R.drawable.beauty_ic_makeup_eyeshadow_sunset_red,     style = 9),  // 晚霞红
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_girl_pink,       R.drawable.beauty_ic_makeup_eyeshadow_girl_pink,       style = 2),  // 少女粉
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_elegant_pink,    R.drawable.beauty_ic_makeup_eyeshadow_elegant_pink,    style = 13), // 气质粉
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_plum_red,        R.drawable.beauty_ic_makeup_eyeshadow_plum_red,        style = 12), // 梅子红
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_caramel_brown,   R.drawable.beauty_ic_makeup_eyeshadow_caramel_brown,   style = 8),  // 焦糖棕
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_vitality_orange, R.drawable.beauty_ic_makeup_eyeshadow_vitality_orange, style = 14), // 元气橘
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_milk_tea,        R.drawable.beauty_ic_makeup_eyeshadow_milk_tea,        style = 11)  // 奶茶色
    )

    private fun buildEyebrowItems() = listOf(
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_lady,     R.drawable.beauty_ic_makeup_eyebrow_lady,     style = 1),  // 淑女
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_gentle,   R.drawable.beauty_ic_makeup_eyebrow_gentle,   style = 2),  // 温润
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_standard, R.drawable.beauty_ic_makeup_eyebrow_standard, style = 3),  // 标准
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_willow,   R.drawable.beauty_ic_makeup_eyebrow_willow,   style = 4),  // 柳叶
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_fluffy,   R.drawable.beauty_ic_makeup_eyebrow_fluffy,   style = 5),  // 茸茸
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_wild,     R.drawable.beauty_ic_makeup_eyebrow_wild,     style = 6),  // 野生
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_thin,     R.drawable.beauty_ic_makeup_eyebrow_thin,     style = 7),  // 细眉
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_heroic,   R.drawable.beauty_ic_makeup_eyebrow_heroic,   style = 8),  // 英朗
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_upright,  R.drawable.beauty_ic_makeup_eyebrow_upright,  style = 9),  // 挺拔
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_flat,     R.drawable.beauty_ic_makeup_eyebrow_flat,     style = 10)  // 平锋
    )
}

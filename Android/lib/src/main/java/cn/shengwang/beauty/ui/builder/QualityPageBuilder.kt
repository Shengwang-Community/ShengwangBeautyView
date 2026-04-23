package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 画质模块页面构建器
 * 负责构建画质（色温、色调、饱和度、亮度）模块的页面信息
 *
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class QualityPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val qualityItems = mutableListOf<BeautyItemInfo>()

        // 开关项
        val isEnabled = beautyConfig.qualityEnable
        qualityItems.add(
            BeautyItemInfo(
                name = if (isEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
                icon = if (isEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
                isSelected = isEnabled,
                showSlider = false,
                type = BeautyItemType.TOGGLE,
                onItemClick = {
                    beautyConfig.qualityEnable = !beautyConfig.qualityEnable
                }
            )
        )

        // 色温
        addQualityItem(
            qualityItems,
            R.string.beauty_effect_temperature,
            R.drawable.beauty_ic_effect_temperature,
            beautyConfig.temperature
        ) { value ->
            beautyConfig.temperature = value
        }
        // 色调
        addQualityItem(
            qualityItems,
            R.string.beauty_effect_hue,
            R.drawable.beauty_ic_effect_hue,
            beautyConfig.hue
        ) { value ->
            beautyConfig.hue = value
        }
        // 饱和度
        addQualityItem(
            qualityItems,
            R.string.beauty_effect_saturation,
            R.drawable.beauty_ic_effect_saturation,
            beautyConfig.saturation
        ) { value ->
            beautyConfig.saturation = value
        }
        // 亮度
        addQualityItem(
            qualityItems,
            R.string.beauty_effect_brightness,
            R.drawable.beauty_ic_effect_brightness,
            beautyConfig.brightness
        ) { value ->
            beautyConfig.brightness = value
        }
        // 对比度
        addQualityItem(
            qualityItems,
            R.string.beauty_effect_contrast_factor,
            R.drawable.beauty_ic_effect_contrast_strength,
            beautyConfig.contrastFactor
        ) { value ->
            beautyConfig.contrastFactor = value
        }

        return BeautyPageInfo(
            R.string.beauty_group_quality,
            qualityItems,
            type = BeautyModule.BEAUTY
        )
    }

    /**
     * 添加单个画质参数项
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值
     * @param onValueChanged 值变化回调
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
                currentValue,
                valueRange = -1.0f..1.0f,
                onValueChanged = onValueChanged
            )
        )
    }
}

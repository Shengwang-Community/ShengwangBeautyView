package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.core.FilterNames
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyPageInfo
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule

/**
 * 滤镜模块页面构建器
 * 负责构建滤镜模块的页面信息
 * 
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class FilterPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val filterItems = mutableListOf<BeautyItemInfo>()

        filterItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_none,
                R.drawable.beauty_ic_none,
                isSelected = beautyConfig.filterName == null,
                showSlider = false,
                type = BeautyItemType.NONE,
                onItemClick = {
                    beautyConfig.filterName = null
                }
            )
        )

        // 滤镜选项
        // 旧版中文命名滤镜
        addFilterItem(filterItems, R.string.beauty_filter_ct, R.drawable.beauty_ic_filter_serene, FilterNames.CT)
        addFilterItem(filterItems, R.string.beauty_filter_nuanhuang, R.drawable.beauty_ic_filter_urban, FilterNames.NUANHUANG)
        addFilterItem(filterItems, R.string.beauty_filter_lvtu, R.drawable.beauty_ic_filter_glow, FilterNames.LVTU)
        addFilterItem(filterItems, R.string.beauty_filter_meishijiaopian, R.drawable.beauty_ic_filter_gilt, FilterNames.MEISHIJIAOPIAN)
        addFilterItem(filterItems, R.string.beauty_filter_landiaojiaopian, R.drawable.beauty_ic_filter_cream, FilterNames.LANDIAOJIAOPIAN)
        addFilterItem(filterItems, R.string.beauty_filter_riza, R.drawable.beauty_ic_filter_latte, FilterNames.RIZA)
        addFilterItem(filterItems, R.string.beauty_filter_jingdu, R.drawable.beauty_ic_filter_summer, FilterNames.JINGDU)
        addFilterItem(filterItems, R.string.beauty_filter_aizhicheng, R.drawable.beauty_ic_filter_daily, FilterNames.AIZHICHENG)
        addFilterItem(filterItems, R.string.beauty_filter_mitao, R.drawable.beauty_ic_filter_genyleman, FilterNames.MITAO)
        addFilterItem(filterItems, R.string.beauty_filter_heijin, R.drawable.beauty_ic_filter_vanila, FilterNames.HEIJIN)
        addFilterItem(filterItems, R.string.beauty_filter_luolita, R.drawable.beauty_ic_filter_bright, FilterNames.LUOLITA)

        return BeautyPageInfo(
            R.string.beauty_group_filter,
            filterItems,
            type = BeautyModule.FILTER
        )
    }

    /**
     * 添加滤镜选项
     * 
     * 1. 初始化时：使用当前选中滤镜的强度值（会从缓存读取）
     * 2. 用户拖动滑块时：更新当前滤镜的强度值（会同步更新缓存）
     * 3. 用户点击切换滤镜时：
     *    - 先获取缓存中该滤镜的强度值（如果用户之前设置过）
     *    - 切换滤镜（filterName），这会触发 SDK 设置默认强度
     *    - 如果缓存中有该滤镜的强度值（无论是否为 0），用缓存的强度值覆盖 SDK 设置的默认值
     *    - 更新 UI 显示的强度值，确保 UI 与 SDK 状态一致
     * 
     * 这样设计的好处：
     * - 每个滤镜的强度值都会被缓存，切换回来时保持用户之前设置的强度
     * - API 层统一管理缓存，UI 层逻辑简单清晰
     * - 易于维护和理解
     */
    private fun addFilterItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        filterName: String
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                beautyConfig.filterStrength,
                isSelected = beautyConfig.filterName == filterName,
                valueRange = 0f..1.0f,
                // 用户拖动滑块时，更新强度值（会同步更新缓存）
                onValueChanged = { value ->
                    beautyConfig.filterStrength = value
                },
                // 用户点击切换滤镜时
                onItemClick = { itemInfo ->
                    // 1. 先获取缓存中该滤镜的强度值（如果用户之前设置过）
                    val cachedStrength = beautyConfig.getFilterStrengthForTemplate(filterName)
                    
                    // 2. 切换滤镜（这会触发 SDK 设置默认强度）
                    beautyConfig.filterName = filterName
                    
                    // 3. 如果缓存中有该滤镜的强度值（无论是否为 0），用缓存的强度值覆盖 SDK 设置的默认值
                    //    这样用户切换回之前的滤镜时，会保持之前设置的强度值（包括用户设置为 0 的情况）
                    cachedStrength?.let {
                        beautyConfig.filterStrength = it
                    }
                    
                    // 4. 更新 UI 显示的强度值，确保与 SDK 状态一致
                    itemInfo.value = beautyConfig.filterStrength
                }
            )
        )
    }
}

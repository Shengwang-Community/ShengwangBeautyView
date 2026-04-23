package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.core.StickerNames
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyPageInfo
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import io.agora.rtc2.IVideoEffectObject

/**
 * 贴纸模块页面构建器
 * 负责构建贴纸模块的页面信息
 * 
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class StickerPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val stickerItems = mutableListOf<BeautyItemInfo>()

        stickerItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_none,
                R.drawable.beauty_ic_none,
                isSelected = beautyConfig.stickerName == null,
                showSlider = false,
                type = BeautyItemType.NONE,
                onItemClick = {
                    beautyConfig.stickerName = null
                }
            )
        )

        // 白兔贴纸
        addStickerItem(stickerItems, R.string.beauty_sticker_2year, R.drawable.beauty_ic_sticker_brush, StickerNames.ANNIVERSARY2)
        addStickerItem(stickerItems, R.string.beauty_sticker_3year, R.drawable.beauty_ic_sticker_cyber_glass, StickerNames.ANNIVERSARY3)
        addStickerItem(stickerItems, R.string.beauty_sticker_love, R.drawable.beauty_ic_sticker_neon_tiara, StickerNames.HEART)
        addStickerItem(stickerItems, R.string.beauty_sticker_hazhijie, R.drawable.beauty_ic_sticker_love_glass, StickerNames.HAZHI)
        addStickerItem(stickerItems, R.string.beauty_sticker_bowknot, R.drawable.beauty_ic_sticker_neon_tiara, StickerNames.BOWKNOT)
        addStickerItem(stickerItems, R.string.beauty_sticker_flowermask, R.drawable.beauty_ic_sticker_love_glass, StickerNames.FLOWER_MASK)
        addStickerItem(stickerItems, R.string.beauty_sticker_goggles, R.drawable.beauty_ic_sticker_neon_tiara, StickerNames.GOGGLES)
        addStickerItem(stickerItems, R.string.beauty_sticker_cateye, R.drawable.beauty_ic_sticker_love_glass, StickerNames.CATEYE)
        addStickerItem(stickerItems, R.string.beauty_sticker_fronttest, R.drawable.beauty_ic_sticker_neon_tiara, StickerNames.FRONTTEST)
        addStickerItem(stickerItems, R.string.beauty_sticker_worldcup, R.drawable.beauty_ic_sticker_love_glass, StickerNames.WORLDCUP)
        addStickerItem(stickerItems, R.string.beauty_sticker_tuyao, R.drawable.beauty_ic_sticker_neon_tiara, StickerNames.TUYAO)
        addStickerItem(stickerItems, R.string.beauty_sticker_bunny_ear1, R.drawable.beauty_ic_sticker_love_glass, StickerNames.BUNNY_EAR)
        addStickerItem(stickerItems, R.string.beauty_sticker_bunny_ear2, R.drawable.beauty_ic_sticker_love_glass, StickerNames.RABBIT_EAR)
        addStickerItem(stickerItems, R.string.beauty_sticker_bunny_eyepatch, R.drawable.beauty_ic_sticker_love_glass, StickerNames.BUNNY_EYEPATCH)
        addStickerItem(stickerItems, R.string.beauty_sticker_bear_eyepatch, R.drawable.beauty_ic_sticker_love_glass, StickerNames.BEAR_EYEPATCH)
        addStickerItem(stickerItems, R.string.beauty_sticker_newyear, R.drawable.beauty_ic_sticker_love_glass, StickerNames.NEW_YEAR)

        // 声网动态贴纸
        // 圣诞节
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_christmas,
            R.drawable.beauty_ic_sticker_christmas,
            StickerNames.CHRISTMAS
        )
        // 章鱼
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_squid,
            R.drawable.beauty_ic_sticker_squid,
            StickerNames.SQUID
        )
        // 猪可爱
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_piggy,
            R.drawable.beauty_ic_sticker_piggy,
            StickerNames.PIGGY
        )
        // 蝴蝶
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_butterfly,
            R.drawable.beauty_ic_sticker_butterfly,
            StickerNames.BUTTERFLY
        )

        return BeautyPageInfo(
            R.string.beauty_group_sticker,
            stickerItems,
            type = IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER
        )
    }

    private fun addStickerItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        stickerName: String
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                isSelected = beautyConfig.stickerName == stickerName,
                showSlider = false,
                onItemClick = {
                    beautyConfig.stickerName = stickerName
                }
            )
        )
    }
}

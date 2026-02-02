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

        // 贴纸选项
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
        // 辫子猫
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_long_cat,
            R.drawable.beauty_ic_sticker_long_cat,
            StickerNames.LONG_CAT
        )
        // 粉色发箍
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_hairhoop,
            R.drawable.beauty_ic_sticker_hairhoop,
            StickerNames.HAIRHOOP
        )
        // 没有烦恼
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_relax_time,
            R.drawable.beauty_ic_sticker_relax_time,
            StickerNames.RELAX_TIME
        )
        // 卡通猫
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_cartoon_cat,
            R.drawable.beauty_ic_sticker_cartoon_cat,
            StickerNames.CARTOON_CAT
        )
        // 蝴蝶
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_butterfly,
            R.drawable.beauty_ic_sticker_butterfly,
            StickerNames.BUTTERFLY
        )
        // 粉刷时光
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_brush,
            R.drawable.beauty_ic_sticker_brush,
            StickerNames.BRUSH
        )
        // 赛博眼镜
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_cyber_glass,
            R.drawable.beauty_ic_sticker_cyber_glass,
            StickerNames.CYBER_GLASS
        )
        // 霓虹皇冠
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_neon_tiara,
            R.drawable.beauty_ic_sticker_neon_tiara,
            StickerNames.NEON_TIARA
        )
        // 爱心眼镜
        addStickerItem(
            stickerItems,
            R.string.beauty_sticker_love_glass,
            R.drawable.beauty_ic_sticker_love_glass,
            StickerNames.LOVE_GLASS
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

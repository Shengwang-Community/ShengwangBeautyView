//
//  StickerPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Sticker module page builder
/// Responsible for building page information for sticker module
internal class StickerPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var stickerItems: [BeautyItemInfo] = []
        
        // None effect item
        stickerItems.append(
            BeautyItemInfo(
                name: "beauty_effect_none",
                icon: UIImage.beautyIcon(named: "beauty_ic_none"),
                isSelected: beautyConfig.stickerName == nil,
                showSlider: false,
                type: .none,
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.stickerName = nil
                }
            )
        )
        
        // Sticker options
        addStickerItem(&stickerItems, name: "beauty_sticker_christmas", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_christmas"), stickerName: StickerNames.christmas)
        addStickerItem(&stickerItems, name: "beauty_sticker_squid", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_squid"), stickerName: StickerNames.squid)
        addStickerItem(&stickerItems, name: "beauty_sticker_piggy", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_piggy"), stickerName: StickerNames.piggy)
        addStickerItem(&stickerItems, name: "beauty_sticker_long_cat", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_long_cat"), stickerName: StickerNames.longCat)
        addStickerItem(&stickerItems, name: "beauty_sticker_hairhoop", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_hairhoop"), stickerName: StickerNames.hairhoop)
        addStickerItem(&stickerItems, name: "beauty_sticker_relax_time", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_relax_time"), stickerName: StickerNames.relaxTime)
        addStickerItem(&stickerItems, name: "beauty_sticker_cartoon_cat", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_cartoon_cat"), stickerName: StickerNames.cartoonCat)
        addStickerItem(&stickerItems, name: "beauty_sticker_butterfly", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_butterfly"), stickerName: StickerNames.butterfly)
        addStickerItem(&stickerItems, name: "beauty_sticker_brush", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_brush"), stickerName: StickerNames.brush)
        addStickerItem(&stickerItems, name: "beauty_sticker_cyber_glass", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_cyber_glass"), stickerName: StickerNames.cyberGlass)
        addStickerItem(&stickerItems, name: "beauty_sticker_neon_tiara", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.neonTiara)
        addStickerItem(&stickerItems, name: "beauty_sticker_love_glass", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.loveGlass)
        
        return BeautyPageInfo(
            name: "beauty_group_sticker",
            itemList: stickerItems,
            type: .sticker
        )
    }
    
    private func addStickerItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        stickerName: String
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                isSelected: beautyConfig.stickerName == stickerName,
                showSlider: false,
                onItemClick: { [weak self] _ in
                    guard let self = self else { return }
                    self.beautyConfig.stickerName = stickerName
                }
            )
        )
    }
}

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
        addStickerItem(&stickerItems, name: "beauty_sticker_2year", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_brush"), stickerName: StickerNames.anniversary2)
        addStickerItem(&stickerItems, name: "beauty_sticker_3year", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_cyber_glass"), stickerName: StickerNames.anniversary3)
        addStickerItem(&stickerItems, name: "beauty_sticker_love", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.heart)
        addStickerItem(&stickerItems, name: "beauty_sticker_hazhijie", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.hazhi)
        addStickerItem(&stickerItems, name: "beauty_sticker_bowknot", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.bowknot)
        addStickerItem(&stickerItems, name: "beauty_sticker_flowermask", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.flowerMask)
        addStickerItem(&stickerItems, name: "beauty_sticker_goggles", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.goggles)
        addStickerItem(&stickerItems, name: "beauty_sticker_cateye", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.cateye)
        addStickerItem(&stickerItems, name: "beauty_sticker_fronttest", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.fronttest)
        addStickerItem(&stickerItems, name: "beauty_sticker_worldcup", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.worldcup)
        addStickerItem(&stickerItems, name: "beauty_sticker_tuyao", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_neon_tiara"), stickerName: StickerNames.tuyao)
        addStickerItem(&stickerItems, name: "beauty_sticker_bunny_ear1", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.bunnyEar)
        addStickerItem(&stickerItems, name: "beauty_sticker_bunny_ear2", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.rabbitEar)
        addStickerItem(&stickerItems, name: "beauty_sticker_bunny_eyepatch", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.bunnyEyepatch)
        addStickerItem(&stickerItems, name: "beauty_sticker_bear_eyepatch", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.bearEyepatch)
        addStickerItem(&stickerItems, name: "beauty_sticker_newyear", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_love_glass"), stickerName: StickerNames.newYear)
        addStickerItem(&stickerItems, name: "beauty_sticker_christmas", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_christmas"), stickerName: StickerNames.christmas)
        addStickerItem(&stickerItems, name: "beauty_sticker_squid", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_squid"), stickerName: StickerNames.squid)
        addStickerItem(&stickerItems, name: "beauty_sticker_piggy", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_piggy"), stickerName: StickerNames.piggy)
        addStickerItem(&stickerItems, name: "beauty_sticker_butterfly", icon: UIImage.beautyIcon(named: "beauty_ic_sticker_butterfly"), stickerName: StickerNames.butterfly)
        
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

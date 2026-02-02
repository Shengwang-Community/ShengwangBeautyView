//
//  IPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation

/// Page builder interface
/// Used to build page information for different modules
internal protocol IPageBuilder {
    /// Build page information
    /// - Returns: BeautyPageInfo page information
    func buildPage() -> BeautyPageInfo
}

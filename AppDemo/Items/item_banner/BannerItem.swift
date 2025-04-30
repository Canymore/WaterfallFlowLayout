//
//  BannerItem.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout

struct BannerItem: ItemProtocol {
    var id: String = ""
    var itemID: String = ""
    
    var layout: ItemLayout {
        .fullFixed(value: 100, ignoreSectionInset: false)
    }
    var diffExtension: String {
        "\(id)_\(itemID)"
    }
}

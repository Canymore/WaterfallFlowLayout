//
//  ImageTextItem.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout

struct ImageTextItem: ItemProtocol {
    
    var id: String = ""
    var itemID: String = ""
    var layout: ItemLayout {
        .fullRatio(value: 6, ignoreSectionInset: false)
    }
    var diffExtension: String {
        "\(id)_\(itemID)"
    }
}

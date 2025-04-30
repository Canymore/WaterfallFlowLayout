//
//  W3H2Item.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout

struct W3H2Item: ItemProtocol {
    var id: String = ""
    var itemID: String = ""
    var layout: ItemLayout {
        .cell(ratio: 3.0 / 2.0)
    }
    var diffExtension: String {
        "\(id)_\(itemID)"
    }
}

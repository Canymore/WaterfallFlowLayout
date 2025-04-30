//
//  W2H3Item.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout

struct W2H3Item: ItemProtocol {
    var id: String = ""
    var itemID: String = ""
    var layout: ItemLayout {
        .cell(ratio: 2.0 / 3.0)
    }
    var diffExtension: String {
        "\(id)_\(itemID)"
    }
}

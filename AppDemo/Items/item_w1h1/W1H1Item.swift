//
//  W1H1Item.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout

struct W1H1Item: ItemProtocol {
    var id: String = ""
    var itemID: String = ""
    var layout: ItemLayout {
        .cell(ratio: 1)
    }
    var diffExtension: String {
        "\(id)_\(itemID)"
    }
}

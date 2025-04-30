//
//  ItemProtocol.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import WaterfallFlowLayout
import KakaJSON

protocol ItemProtocol: Convertible {
    /// id，数据中的唯一标识
    var id: String { get set }
    /// 组件Id
    var itemID: String { get set }
    
    /// 组件布局
    var layout: ItemLayout { get }
    /// 组件diff时依赖的字符串
    var diffExtension: String { get }
}

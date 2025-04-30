//
//  WaterfallLayout.swift
//  WaterfallFlowLayout
//
//  Created by 曹海洋 on 2025/4/30.
//

import Foundation
import UIKit

public enum ItemLayout {
    /// 按列数自动计算宽度，根据宽度和ratio计算高度。ratio：宽高比
    case cell(ratio: Double)
    /// 宽度充满Section的宽度
    /// value: 固定高度
    /// ignoreSectionInset: 计算宽度时是否忽略sectionInset
    case fullFixed(value: CGFloat, ignoreSectionInset: Bool)
    /// 宽度充满Section的宽度
    /// value: 宽高比，根据宽度和ratio计算高度
    /// ignoreSectionInset: 计算宽度时是否忽略sectionInset
    case fullRatio(value: Double, ignoreSectionInset: Bool)
    /// 固定大小的cell，独占一行，居左，居中，居右
    case fullFixedSize(value: CGSize, alignment: Alignment, ignoreSectionInset: Bool)
    
    /// 固定cell大小时，cell摆放位置
    public enum Alignment {
        case left
        case center
        case right
    }
}

public protocol WaterfallLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        layoutForItemAt indexPath: IndexPath) -> ItemLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        columnCountForSectionAt section: Int) -> Int?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        heightForHeaderInSectionAt section: Int) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        heightForFooterInSectionAt section: Int) -> CGFloat?
}
extension WaterfallLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets? { return nil }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat? { return nil }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat? { return nil }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        columnCountForSectionAt section: Int) -> Int? { return nil }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        heightForHeaderInSectionAt section: Int) -> CGFloat? { return nil }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        heightForFooterInSectionAt section: Int) -> CGFloat? { return nil }
}

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

extension WaterfallLayout {
    public enum ItemRenderDirection: Int {
        case shortestFirst
        case leftToRight
        case rightToLeft
    }
    
    public enum SectionInsetReference {
        case fromContentInset
        case fromLayoutMargins
        @available(iOS 11, *)
        case fromSafeArea
    }
}

public class WaterfallLayout: UICollectionViewLayout {
    /// 列数量
    public var columnCount: Int = 2 {
        didSet {
            invalidateLayout()
        }
    }
    /// 行间距
    public var minimumLineSpacing: CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    /// 列间距
    public var minimumInteritemSpacing: CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }

    public var headerHeight: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }

    public var footerHeight: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }

    public var sectionInset: UIEdgeInsets = .zero {
        didSet {
            invalidateLayout()
        }
    }

    public var itemRenderDirection: ItemRenderDirection = .shortestFirst {
        didSet {
            invalidateLayout()
        }
    }

    public var sectionInsetReference: SectionInsetReference = .fromContentInset {
        didSet {
            invalidateLayout()
        }
    }

    public var delegate: WaterfallLayoutDelegate? {
        get {
            return collectionView!.delegate as? WaterfallLayoutDelegate
        }
    }

    private var columnHeights: [[CGFloat]] = []
    private var sectionItemAttributes: [[UICollectionViewLayoutAttributes]] = []
    internal private(set) var allItemAttributes: [UICollectionViewLayoutAttributes] = []
    private var headersAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    private var footersAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    private var unionRects: [CGRect] = []
    private let unionSize = 20

    private func columnCount(forSection section: Int) -> Int {
        return delegate?.collectionView(collectionView!, layout: self, columnCountForSectionAt: section) ?? columnCount
    }

    private var collectionViewContentWidth: CGFloat {
        let insets: UIEdgeInsets
        switch sectionInsetReference {
        case .fromContentInset:
            insets = collectionView!.contentInset
        case .fromSafeArea:
            if #available(iOS 11.0, *) {
                insets = collectionView!.safeAreaInsets
            } else {
                insets = .zero
            }
        case .fromLayoutMargins:
            insets = collectionView!.layoutMargins
        }
        return collectionView!.bounds.size.width - insets.left - insets.right
    }

    private func collectionViewContentWidth(ofSection section: Int) -> CGFloat {
        let inset = delegate?.collectionView(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
        return collectionViewContentWidth - inset.left - inset.right
    }

    public func itemWidth(inSection section: Int) -> CGFloat {
        let columnCount = self.columnCount(forSection: section)
        let spaceColumCount = CGFloat(columnCount - 1)
        let width = collectionViewContentWidth(ofSection: section)
        let minimumInteritemSpacing = delegate?.collectionView(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
        return floor((width - (spaceColumCount * minimumInteritemSpacing)) / CGFloat(columnCount))
    }

    override public func prepare() {
        super.prepare()

        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }

        headersAttributes = [:]
        footersAttributes = [:]
        unionRects = []
        allItemAttributes = []
        sectionItemAttributes = []
        columnHeights = (0 ..< numberOfSections).map { section in
            let columnCount = self.columnCount(forSection: section)
            let sectionColumnHeights = (0 ..< columnCount).map { CGFloat($0) }
            return sectionColumnHeights
        }

        var top: CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()

        for section in 0 ..< numberOfSections {
            // MARK: 1. Get section-specific metrics (minimumLineSpacing, minimumInteritemSpacing, sectionInset)
            let minimumLineSpacing = delegate?.collectionView(collectionView!, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
            let minimumInteritemSpacing = delegate?.collectionView(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
            let sectionInsets = delegate?.collectionView(collectionView!, layout: self, insetForSectionAt: section) ?? self.sectionInset
            let columnCount = columnHeights[section].count
            let itemWidth = self.itemWidth(inSection: section)

            // MARK: 2. Section header
            let heightHeader = delegate?.collectionView(collectionView!, layout: self, heightForHeaderInSectionAt: section)
                ?? self.headerHeight
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView!.bounds.size.width, height: heightHeader)
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)

                top = attributes.frame.maxY
            }
            top += sectionInsets.top
            columnHeights[section] = [CGFloat](repeating: top, count: columnCount)

            // MARK: 3. Section items
            let itemCount = collectionView!.numberOfItems(inSection: section)
            var itemAttributes: [UICollectionViewLayoutAttributes] = []
            
            let collectionViewW = collectionView!.frame.width
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                var nextColumnIndex: Int
                var xOffset: CGFloat
                var yOffset: CGFloat
                var cellWidth: CGFloat
                var cellHeight: CGFloat
                // 只改变当前列的高度
                var currentColumnOnly: Bool
                
                let itemLayout = delegate?.collectionView(collectionView!, layout: self, layoutForItemAt: indexPath) ?? .cell(ratio: 1.0)
                switch itemLayout {
                case .cell(let ratio):
                    nextColumnIndex = nextColumnIndexForItem(idx, inSection: section)
                    xOffset = sectionInsets.left + (itemWidth + minimumInteritemSpacing) * CGFloat(nextColumnIndex)
                    yOffset = columnHeights[section][nextColumnIndex]
                    cellWidth = itemWidth
                    cellHeight = itemWidth / (ratio > 0 ? ratio : 1.0)
                    currentColumnOnly = true
                case .fullFixed(let value, let ignoreSectionInset):
                    nextColumnIndex = longestColumnIndex(inSection: section)
                    xOffset = ignoreSectionInset ? 0 : sectionInsets.left
                    yOffset = columnHeights[section][nextColumnIndex]
                    cellWidth = ignoreSectionInset ? collectionViewContentWidth : collectionViewContentWidth(ofSection: section)
                    cellHeight = value
                    currentColumnOnly = false
                case .fullRatio(let value, let ignoreSectionInset):
                    nextColumnIndex = longestColumnIndex(inSection: section)
                    xOffset = ignoreSectionInset ? 0 : sectionInsets.left
                    yOffset = columnHeights[section][nextColumnIndex]
                    cellWidth = ignoreSectionInset ? collectionViewContentWidth : collectionViewContentWidth(ofSection: section)
                    cellHeight = cellWidth / (value > 0 ? value : 1.0)
                    currentColumnOnly = false
                case .fullFixedSize(value: let size, alignment: let alignment, ignoreSectionInset: let ignoreSectionInset):
                    nextColumnIndex = longestColumnIndex(inSection: section)
                    switch alignment {
                    case .left:
                        // 居左
                        xOffset = ignoreSectionInset ? 0 : sectionInsets.left
                    case .right:
                        // 居右
                        xOffset = ignoreSectionInset ? (collectionViewW - size.width) : (collectionViewW - sectionInsets.right - size.width)
                    default:
                        // 居中
                        xOffset = ignoreSectionInset ?
                        (collectionViewW - size.width) / 2.0 :
                        (sectionInsets.left + (collectionViewW - sectionInsets.left - sectionInsets.right - size.width) / 2.0)
                    }
                    yOffset = columnHeights[section][nextColumnIndex]
                    cellWidth = size.width
                    cellHeight = size.height
                    currentColumnOnly = false
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                if currentColumnOnly {
                    columnHeights[section][nextColumnIndex] = attributes.frame.maxY + minimumLineSpacing
                } else {
                    for i in 0 ..< columnHeights[section].count {
                        columnHeights[section][i] = attributes.frame.maxY + minimumLineSpacing
                    }
                }
            }
            sectionItemAttributes.append(itemAttributes)

            // MARK: 4. Section footer
            let columnIndex  = longestColumnIndex(inSection: section)
            top = columnHeights[section][columnIndex] - minimumLineSpacing + sectionInsets.bottom
            let footerHeight = delegate?.collectionView(collectionView!, layout: self, heightForFooterInSectionAt: section) ?? self.footerHeight

            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView!.bounds.size.width, height: footerHeight)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }

            columnHeights[section] = [CGFloat](repeating: top, count: columnCount)
        }

        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }

    override public var collectionViewContentSize: CGSize {
        if collectionView!.numberOfSections == 0 {
            return .zero
        }

        var contentSize = collectionView!.bounds.size
        contentSize.width = collectionViewContentWidth

        if let height = columnHeights.last?.first {
            contentSize.height = height
            return contentSize
        }
        return .zero
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        if indexPath.item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        var attribute: UICollectionViewLayoutAttributes?
        if elementKind == UICollectionView.elementKindSectionHeader {
            attribute = headersAttributes[indexPath.section]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            attribute = footersAttributes[indexPath.section]
        }
        return attribute ?? UICollectionViewLayoutAttributes()
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, allItemAttributes.count)
        }
        return allItemAttributes[begin..<end]
            .filter { rect.intersects($0.frame) }
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }

    /// Find the shortest column.
    ///
    /// - Returns: index for the shortest column
    private func shortestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    /// Find the longest column.
    ///
    /// - Returns: index for the longest column
    private func longestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .max(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    /// Find the index for the next column.
    ///
    /// - Returns: index for the next column
    private func nextColumnIndexForItem(_ item: Int, inSection section: Int) -> Int {
        var index = 0
        let columnCount = self.columnCount(forSection: section)
        switch itemRenderDirection {
        case .shortestFirst :
            index = shortestColumnIndex(inSection: section)
        case .leftToRight :
            index = item % columnCount
        case .rightToLeft:
            index = (columnCount - 1) - (item % columnCount)
        }
        return index
    }
}


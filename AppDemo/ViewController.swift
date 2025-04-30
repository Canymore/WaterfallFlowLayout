//
//  ViewController.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import UIKit
import WaterfallFlowLayout
import KakaJSON

let itemCells: [String: (ItemProtocol.Type, Cell.Type)] = [
    "item_banner": (BannerItem.self, BannerCell.self),
    "item_imageText": (ImageTextItem.self, ImageTextCell.self),
    "item_w1h1": (W1H1Item.self, W1H1Cell.self),
    "item_w2h3": (W2H3Item.self, W2H3Cell.self),
    "item_w3h2": (W3H2Item.self, W3H2Cell.self),
]
let mockData: [[String: Any]] = [
    ["id": 1, "itemID": "item_banner"],
    ["id": 2, "itemID": "item_w2h3"],
    ["id": 3, "itemID": "item_w1h1"],
    ["id": 4, "itemID": "item_w2h3"],
    ["id": 5, "itemID": "item_w1h1"],
    ["id": 6, "itemID": "item_imageText"],
    ["id": 7, "itemID": "item_w2h3"],
    ["id": 8, "itemID": "item_w3h2"],
    ["id": 9, "itemID": "item_w2h3"],
    ["id": 10, "itemID": "item_w2h3"],
    ["id": 11, "itemID": "item_w3h2"],
    ["id": 12, "itemID": "item_w2h3"],
    ["id": 13, "itemID": "item_w1h1"],
    ["id": 14, "itemID": "item_w2h3"],
    ["id": 15, "itemID": "item_w2h3"],
    ["id": 16, "itemID": "item_w2h3"],
]

class ViewController: UIViewController {
    
    var items: [ItemProtocol] = mockData.compactMap {
        if let itemID = $0["itemID"] as? String, let itemClass = itemCells[itemID]?.0 {
            return $0.kj.model(itemClass)
        }
        return nil
    }
    
    var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        itemCells.forEach {
            view.register($0.value.1, forCellWithReuseIdentifier: $0.key)
        }
        return view
    }()
    
    override func loadView() {
        super.loadView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeInsets = view.safeAreaInsets
        let viewW = view.frame.width
        let viewH = view.frame.height
        collectionView.frame = CGRect(x: safeInsets.left, y: safeInsets.top,
                                      width: viewW - safeInsets.left - safeInsets.right,
                                      height: viewH - safeInsets.top - safeInsets.bottom)
    }

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.itemID, for: indexPath)
        if let cell = cell as? Cell {
            cell.collectionView = collectionView
            cell.viewController = self
            cell.setItem(item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, layoutForItemAt indexPath: IndexPath) -> WaterfallFlowLayout.ItemLayout {
        let item = items[indexPath.item]
        return item.layout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? Cell {
            cell.didTapCell()
        }
    }
}



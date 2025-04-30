//
//  Cell.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import UIKit

class Cell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var collectionView: UICollectionView?
    weak var viewController: UIViewController?
    
    var item: ItemProtocol?
    func setItem(_ item: ItemProtocol) {
        self.item = item
    }
    func didTapCell() {
        let subVC = DetailViewController()
        if let title = item?.diffExtension {
            subVC.detailTitle = title
        }
        self.viewController?.navigationController?.pushViewController(subVC, animated: true)
    }
}

//
//  W2H3Cell.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import UIKit

class W2H3Cell: Cell {
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = .systemGreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
    
    override func setItem(_ item: any ItemProtocol) {
        super.setItem(item)
        guard let item = item as? W2H3Item else { return }
        label.text = "\(item.id)"
    }
}

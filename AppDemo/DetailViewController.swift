//
//  DetailViewController.swift
//  AppDemo
//
//  Created by 曹海洋 on 2025/4/30.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = detailTitle
        view.backgroundColor = .white
    }
}

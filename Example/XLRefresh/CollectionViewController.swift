//
//  CollectionViewController.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/7.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import XLRefresh

class CollectionViewController: UIViewController {

    lazy var collectionView: UICollectionView = { [weak self] in

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 400)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        let collectionView = UICollectionView(frame: self!.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "iidd")
        
        return collectionView
        
    }()
    var fakeData: NSInteger = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        
        collectionView.xl_left = XLRefreshNormalLeft.leftWithRefreshing { [weak self] in
            guard let `self` = self else { return }
            self.loadNewData()
        }
        collectionView.xl_right = XLRefreshNormalRight.rightWithRefreshing { [weak self] in
            guard let `self` = self else { return }
            self.loadMoreData()
        }
        
//        collectionView.xl_right = XLRefreshAutoNormalFooter.footerWithRefreshing { [weak self] in
//            guard let `self` = self else { return }
//            self.loadMoreData()
//        }
        
//        collectionView.xl_header = XLRefreshNormalHeader.headerWithRefreshing { [weak self] in
//            guard let `self` = self else { return }
//            self.loadNewData()
//        }
//
//        collectionView.xl_footer = XLRefreshAutoNormalFooter.footerWithRefreshing { [weak self] in
//            guard let `self` = self else { return }
//            self.loadMoreData()
//        }
    }
    /// 加载新数据 header
    @objc private func loadNewData() {
        
        fakeData = 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            /// 刷新tableView
            self.collectionView.reloadData()
            /// 结束刷新
            self.collectionView.xl_left?.endRefreshing()
        }
    }
    
    /// 加载更多的数据 footer
    @objc private func loadMoreData() {
        
        fakeData += 5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            /// 刷新tableView
            self.collectionView.reloadData()
            /// 结束刷新
            /// 结束刷新
            if self.fakeData > 15 {
                self.collectionView.xl_right?.endRefreshingWithNoMoreData()
            } else {
                self.collectionView.xl_right?.endRefreshing()
            }
        }
    }
    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1.0)
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iidd", for: indexPath)
        
        cell.backgroundColor = randomColor()
        
        return cell
    }
}


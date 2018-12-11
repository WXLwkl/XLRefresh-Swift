//
//  TestViewController.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import XLRefresh

class TestViewController: UIViewController {

    deinit {
        NSLog("释放了。。。")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.tableFooterView = UIView();
        return tableView
    }()
    
    /// 假数据
    lazy var fakeData: [String] = {
        let data = [String]()
        for _ in 0...5 {
            let string = "随机数据:---->\(arc4random_uniform(100000))"
        }
        return data
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        self.view.addSubview(tableView);
        
//        tableView.xl_header = XLRefreshHeader.headerWithRefreshing { [weak self] in
//            guard let `self` = self else { return }
//            self.loadNewData()
//        }
        
//        tableView.xl_header = TaobaoHeader.headerWithRefresing(target: self, action: #selector(TestViewController.loadNewData))
        tableView.xl_header = TaobaoHeader.headerWithRefresing(target: self, action: #selector(TestViewController.loadNewData))
        
        
        tableView.xl_footer = XLRefreshBackNormalFooter.footerWithRefreshing { [weak self] in
            guard let `self` = self else { return }
            self.loadMoreData()
        }
        tableView.xl_header?.beginRefreshing()
    }
    /// 加载更多的数据 footer
    @objc private func loadMoreData() {
        for _ in 0...5 {
            let string = "随机数据:---->\(arc4random_uniform(100000))"
            fakeData.append(string)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            /// 刷新tableView
            self.tableView.reloadData()
            /// 结束刷新
            if self.fakeData.count > 30 {
                self.tableView.xl_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.xl_footer?.endRefreshing()
            }
            
        }
    }

    /// 加载新数据 header
    @objc private func loadNewData() {
        for _ in 0...5 {
            let string = "随机数据:---->\(arc4random_uniform(100000))"
            fakeData.insert(string, at: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            /// 刷新tableView
            self.tableView.reloadData()
            /// 结束刷新
            self.tableView.xl_header?.endRefreshing()
        }
    }
    
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "id")
        if  cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "id")
        }
        cell?.textLabel?.text = fakeData[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = CollectionViewController()
        navigationController?.pushViewController(collection, animated: true)
    }
}

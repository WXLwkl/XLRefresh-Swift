//
//  ViewController.swift
//  XLRefresh
//
//  Created by WXLwkl on 12/11/2018.
//  Copyright (c) 2018 WXLwkl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button: UIButton = UIButton(type: .custom)
        button.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        button.setTitle("点击", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(ViewController.goNext), for: .touchUpInside)
        self.view.addSubview(button)
        
        let web: UIButton = UIButton(type: .custom)
        web.frame = CGRect(x: 50, y: 210, width: 200, height: 100)
        web.setTitle("web", for: .normal)
        web.setTitleColor(UIColor.red, for: .normal)
        web.addTarget(self, action: #selector(ViewController.goWeb), for: .touchUpInside)
        self.view.addSubview(web)
    }
    
    @objc func goNext() {
        let next = TestViewController()
        navigationController?.pushViewController(next, animated: true)
        
    }
    
    @objc func goWeb() {
        let web = WebViewController()
        navigationController?.pushViewController(web, animated: true)
    }
    
}


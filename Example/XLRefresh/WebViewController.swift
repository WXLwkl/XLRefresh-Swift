//
//  WebViewController.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/7.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import XLRefresh

class WebViewController: UIViewController,UIWebViewDelegate {

    var webview:UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview = UIWebView(frame:view.bounds)
        self.webview.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.webview.backgroundColor = UIColor.white
        view.addSubview(self.webview)
        
        self.webview.scrollView.xl_header =  XLRefreshNormalHeader.headerWithRefreshing{ [weak self] in
        
            if self?.webview.request != nil{
                self?.webview.reload()
            }else{
                let url = URL(string: "https://www.baidu.com")
                let request = URLRequest(url: url!)
                self?.webview.loadRequest(request)
            }
        }
        let url = URL(string: "https://www.baidu.com")
        let request = URLRequest(url: url!)
        self.webview.loadRequest(request)
        self.webview.delegate = self
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webview.scrollView.xl_header?.endRefreshing()
    }

}

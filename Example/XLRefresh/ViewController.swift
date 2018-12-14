//
//  ViewController.swift
//  XLRefresh
//
//  Created by WXLwkl on 12/11/2018.
//  Copyright (c) 2018 WXLwkl. All rights reserved.
//

import UIKit

struct SectionModel {
    var rowsCount:Int
    var sectionTitle:String
    var rowsTitles:[String]
    var rowsTargetControlerNames:[String]
}



private let kNormalCellID = "kNormalCellID"

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.tableFooterView = UIView();
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kNormalCellID)
        return tableView
    }()
    
    var models = [SectionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "刷新"
        
        
        self.view.addSubview(tableView);
        
//        fakeData.append("Header/Footer")
//        fakeData.append("Left/Right")
//        fakeData.append("web")
//
//        fakeData.append("taobao")
//        fakeData.append("boss")
        
        let section0 = SectionModel(rowsCount: 3, sectionTitle: "Default", rowsTitles: ["Header/Footer", "Left/Right", "web"], rowsTargetControlerNames: ["TestViewController", "CollectionViewController", "WebViewController"])
        
        let section1 = SectionModel(rowsCount: 2, sectionTitle: "Custom", rowsTitles: ["taobao", "boss"], rowsTargetControlerNames: ["TestViewController", "TestViewController"])
        models.append(section0)
        models.append(section1)
        
        
//        let button: UIButton = UIButton(type: .custom)
//        button.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
//        button.setTitle("点击", for: .normal)
//        button.setTitleColor(UIColor.red, for: .normal)
//        button.addTarget(self, action: #selector(ViewController.goNext), for: .touchUpInside)
//        self.view.addSubview(button)
//
//        let web: UIButton = UIButton(type: .custom)
//        web.frame = CGRect(x: 50, y: 210, width: 200, height: 100)
//        web.setTitle("web", for: .normal)
//        web.setTitleColor(UIColor.red, for: .normal)
//        web.addTarget(self, action: #selector(ViewController.goWeb), for: .touchUpInside)
//        self.view.addSubview(web)
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = models[section]
        return sectionModel.rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNormalCellID)
        let sectionModel = models[(indexPath as NSIndexPath).section]
        cell?.textLabel?.text = sectionModel.rowsTitles[(indexPath as NSIndexPath).row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = models[section]
        return sectionModel.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let sectionModel = models[(indexPath as NSIndexPath).section]
        let childControllerName = sectionModel.rowsTargetControlerNames[(indexPath as NSIndexPath).row]
        
        if childControllerName == "TestViewController" {
            
            let type = sectionModel.rowsTitles[(indexPath as NSIndexPath).row]
            
            let vc = TestViewController()
            
            if type == "taobao" {
                vc.refreshType = .taobao
            } else if type == "boss" {
                vc.refreshType = .boss
            }
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        guard let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] else {
            print("命名空间不存在")
            return
        }
             // 2.通过命名空间和类名转换成类
        let cls : AnyClass? = NSClassFromString((clsName as! String) + "." + childControllerName)
        // swift 中通过Class创建一个对象,必须告诉系统Class的类型
        guard let clsType = cls as? UIViewController.Type else {
            print("无法转换成UIViewController")
            return
        }
        // 3.通过Class创建对象
        let childController = clsType.init()
        self.navigationController?.pushViewController(childController, animated: true)
        
    }
}

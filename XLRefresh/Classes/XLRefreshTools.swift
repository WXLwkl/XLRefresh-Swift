//
//  XLRefresh.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//


import UIKit

typealias XLReloadDataHandler = (_ totalCount: Int) -> ()

extension NSObject {
    class func exchangeInstanceMethod(m1: Selector, m2: Selector) {
        let method1 = class_getInstanceMethod(self, m1)
        let method2 = class_getInstanceMethod(self, m2)
        
        let didAddMethod = class_addMethod(self, m1, method_getImplementation(method2!), method_getTypeEncoding(method2!))
        if didAddMethod {
            class_replaceMethod(self, m2, method_getImplementation(method1!), method_getTypeEncoding(method1!))
        } else {
            method_exchangeImplementations(method1!, method2!)
        }
    }
}


public extension UIScrollView {
    
    private struct StorageKey {
        static var refreshHeader = "refreshHeader"
        static var refreshFooter = "refreshFooter"
        static var refreshLeft   = "refreshLeft"
        static var refreshRight  = "refreshRight"
        static var reloadHandler = "reloadHandler"
    }
    
    /// header
    public var xl_header: XLRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &StorageKey.refreshHeader) as? XLRefreshHeader
        }
        set {
            
            guard xl_header != newValue else { return }
            xl_header?.removeFromSuperview()
            
            willChangeValue(forKey: "xl_header")
            objc_setAssociatedObject(self, &StorageKey.refreshHeader, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "xl_header")
            guard let header = xl_header else { return }
            insertSubview(header, at: 0)
        }
    }
    /// footer
    public var xl_footer: XLRefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &StorageKey.refreshFooter) as? XLRefreshFooter
        }
        set {
            guard xl_footer != newValue else { return }
            xl_footer?.removeFromSuperview()
            
            willChangeValue(forKey: "xl_footer")
            objc_setAssociatedObject(self, &StorageKey.refreshFooter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "xl_footer")
            
            guard let footer = xl_footer else { return }
            insertSubview(footer, at: 0)
        }
    }
    
    /// left
    public var xl_left: XLRefreshLeft? {
        get {
            return objc_getAssociatedObject(self, &StorageKey.refreshLeft) as? XLRefreshLeft
        }
        set {
            guard xl_left != newValue else { return }
            xl_left?.removeFromSuperview()
            
            willChangeValue(forKey: "xl_left")
            objc_setAssociatedObject(self, &StorageKey.refreshLeft, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "xl_left")
            
            guard let left = xl_left else { return }
            insertSubview(left, at: 0)
        }
    }
    
    /// right
    public var xl_right: XLRefreshRight? {
        get {
            return objc_getAssociatedObject(self, &StorageKey.refreshRight) as? XLRefreshRight
        }
        set {
            guard xl_right != newValue else { return }
            xl_right?.removeFromSuperview()
            
            willChangeValue(forKey: "xl_right")
            objc_setAssociatedObject(self, &StorageKey.refreshRight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "xl_right")
            
            guard let right = xl_right else { return }
            insertSubview(right, at: 0)
        }
    }
    
    internal var xl_reloadDataHandler: XLReloadDataHandler? {
        get {
            if let wrapper = objc_getAssociatedObject(self, &StorageKey.reloadHandler) as? XLReloadDataHandlerWrapper {
                return wrapper.reloadDataHanader
            } else {
                return nil
            }
        }
        set {
            let wrapper = XLReloadDataHandlerWrapper(value: newValue)
            objc_setAssociatedObject(self, &StorageKey.reloadHandler, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var xl_totalDataCount: Int {
        var totalCount: Int = 0
        if isKind(of: UITableView.classForCoder()) {
            let tableView = self as! UITableView
            for section in 0 ..< tableView.numberOfSections {
                totalCount += tableView.numberOfRows(inSection: section)
            }
        } else if isKind(of: UICollectionView.classForCoder()) {
            let collectionView = self as! UICollectionView
            for section in 0 ..< collectionView.numberOfSections {
                totalCount += collectionView.numberOfItems(inSection: section)
            }
        }
        return totalCount;
    }
    internal func executeReloadDataBlock() {
        xl_reloadDataHandler?(xl_totalDataCount)
    }
}

extension UITableView {
    fileprivate static let once: Void = {
        UITableView.exchangeInstanceMethod(m1: #selector(UITableView.reloadData),
                                           m2: #selector(UITableView.xl_reloadData))
    }()
    @objc private func xl_reloadData() {
        xl_reloadData()
        executeReloadDataBlock()
    }
}

extension UICollectionView {
    
    fileprivate static let once: Void = {
        UICollectionView.exchangeInstanceMethod(m1: #selector(UICollectionView.reloadData),
                                                m2: #selector(UICollectionView.xl_reloadData))
    }()
    
    @objc private func xl_reloadData() {
        xl_reloadData()
        executeReloadDataBlock()
    }
}


fileprivate struct XLReloadDataHandlerWrapper {
    var reloadDataHanader: XLReloadDataHandler?
    init(value: XLReloadDataHandler?) {
        self.reloadDataHanader = value
    }
}

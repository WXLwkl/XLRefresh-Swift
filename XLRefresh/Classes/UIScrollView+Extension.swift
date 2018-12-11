//
//  UIScrollView+Extension.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    var xl_inset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset
            }
            return self.contentInset
        }
    }
    
    var xl_insertT: CGFloat {
        get {
            return self.xl_inset.top
        }
        set {
            var insert = self.contentInset;
            insert.top = newValue
            if #available(iOS 11.0, *) {
                insert.top -= (self.adjustedContentInset.top - self.contentInset.top)
            }
            self.contentInset = insert
        }
    }
    
    var xl_insertL: CGFloat {
        get {
            return self.xl_inset.left
        }
        set {
            var insert = self.contentInset;
            insert.left = newValue
            if #available(iOS 11.0, *) {
                insert.left -= (self.adjustedContentInset.left - self.contentInset.left)
            }
            self.contentInset = insert
        }
    }
    var xl_insertB: CGFloat {
        get {
            return self.xl_inset.bottom
        }
        set {
            var insert = self.contentInset;
            insert.bottom = newValue
            if #available(iOS 11.0, *) {
                insert.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom)
            }
            self.contentInset = insert
        }
    }
    var xl_insertR: CGFloat {
        get {
            return self.xl_inset.right
        }
        set {
            var insert = self.contentInset;
            insert.right = newValue
            if #available(iOS 11.0, *) {
                insert.right -= (self.adjustedContentInset.right - self.contentInset.right)
            }
            self.contentInset = insert
        }
    }
    
    var xl_offsetX: CGFloat {
        get {
            return self.contentOffset.x
        }
        set {
            var offset = self.contentOffset
            offset.x = newValue
            self.contentOffset = offset
        }
    }
    
    var xl_offsetY: CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            var offset = self.contentOffset
            offset.y = newValue
            self.contentOffset = offset
        }
    }
    var xl_contentW: CGFloat {
        get {
            return self.contentSize.width
        }
        set {
            var size = self.contentSize
            size.width = newValue
            self.contentSize = size
        }
    }
    var xl_contentH: CGFloat {
        get {
            return self.contentSize.height
        }
        set {
            var size = self.contentSize
            size.height = newValue
            self.contentSize = size
        }
    }
}

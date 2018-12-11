//
//  UIView+Extension.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public extension UIView {
    var xl_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    var xl_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    var xl_width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            return self.frame.size.width = newValue
        }
    }
    var xl_height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    var xl_size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
    var xl_origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
}

//
//  UILabel+Extension.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import Foundation

public extension UILabel {
    
    /// 快速创建lable
    static func xl_label() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        label.autoresizingMask = [.flexibleWidth]
        label.textAlignment = .center
        return label
    }
    var xl_textWidth: CGFloat {
        let size = CGSize(width: Int.max, height: Int.max)
        guard let text = self.text else { return 0 }
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics, .truncatesLastVisibleLine]
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : self.font]
        let width = (text as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil).size.width
        return width
    }
}

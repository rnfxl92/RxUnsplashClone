//
//  UIView+Attribute.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/21.
//

import UIKit

@IBDesignable
extension UIView {
    // Border
    @IBInspectable
    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get { return layer.borderColor.map(UIColor.init) }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    // CornerRadius
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue
            clipsToBounds = newValue > 0 } // 내부 View가 밖으로 튀어나오지 않도록...
    }
}

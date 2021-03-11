//
//  UICollectionView+visibleIndexPath.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/28.
//

import UIKit

extension UICollectionView {
    
    var visibleIndexPath: IndexPath? {
        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        return indexPathForItem(at: visiblePoint)
    }
}

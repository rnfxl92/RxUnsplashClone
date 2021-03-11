//
//  Box.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/21.
//

import Foundation

final class Box<T> {
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

extension Box where T == [Photo] {
    func appendValue(_ value: T) {
        self.value.append(contentsOf: value)
    }
}

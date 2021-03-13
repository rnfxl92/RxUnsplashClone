//
//  SceneCoordinatorType.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType: class {
    @discardableResult
    func transition(to Scene: Scene, using style: TranstionStyle, animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}

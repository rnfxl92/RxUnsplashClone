//
//  SceneCoordinatorType.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import Foundation

protocol SceneCoordinatorType: class {

    func transition(to scene: Scene, using style: TranstionStyle, animated: Bool)
    func close(animated: Bool)
    
}

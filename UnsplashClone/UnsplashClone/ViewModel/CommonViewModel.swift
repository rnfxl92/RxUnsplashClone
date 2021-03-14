//
//  CommonViewModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/14.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel: NSObject {
    let sceneCoordinator: SceneCoordinatorType
    let photoApi: PhotoApiType
    
    init(sceneCoordinator: SceneCoordinatorType, photoApi: PhotoApiType, imageService: ImageServicing) {
        self.sceneCoordinator = sceneCoordinator
        self.photoApi = photoApi
    }
}

//
//  TransitionModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import Foundation

enum TranstionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}

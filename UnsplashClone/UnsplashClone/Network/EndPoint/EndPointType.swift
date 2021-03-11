//
//  EndPoint.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import Foundation

protocol EndPointType {
    var url: URL? { get }
    var headers: HTTPHeaders? { get }
    var method: HTTPMethod { get }
}

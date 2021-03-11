//
//  ImageServicing.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/16.
//

import UIKit

protocol ImageServicing {
    
    func imageURL(endPoint: EndPointType, completion: @escaping (Result<UIImage?, NetworkError>) -> Void)
    
    func imageURLFromServer(endPoint: EndPointType, completion: @escaping(Result<UIImage?, NetworkError>) -> Void)
    
}

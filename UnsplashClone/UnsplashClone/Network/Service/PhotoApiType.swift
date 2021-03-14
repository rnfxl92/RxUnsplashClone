//
//  PhotoApiType.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/14.
//

import UIKit
import RxSwift

protocol PhotoApiType {
    
    @discardableResult
    func fetchRandomPhoto() -> Observable<Photo?>

    @discardableResult
    func fetchPhotos(page: Int, perPage: Int) -> Observable<[Photo]>

    @discardableResult
    func fetchSearchedPhotos(page: Int, perPage: Int, query: String) -> Observable<[Photo]>
    
    @discardableResult
    func fetchImage(endPoint: EndPointType) -> Observable<UIImage?>
}

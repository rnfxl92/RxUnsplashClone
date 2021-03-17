//
//  UnsplashPhotoApi.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/14.
//

import UIKit
import RxSwift

class UnsplashPhotoApi: PhotoApiType {
    private let urlSession = URLSession.shared
    private let imageCache = NSCache<NSString, UIImage>()
    
    @discardableResult
    func fetchRandomPhoto() -> Observable<Photo?> {
        guard let url = UnsplashEndPoint.randomPhoto.url else {
            return Observable.error(NetworkError.urlNotSupport)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = UnsplashEndPoint.randomPhoto.method.rawValue
        request.allHTTPHeaderFields = UnsplashEndPoint.randomPhoto.headers
        
        return urlSession.rx
            .data(request: request)
            .map { data -> Photo? in
                let decoder = JSONDecoder()
                
                return try
                    decoder.decode(Photo.self, from: data)
            }
            .catchAndReturn(nil)
    }
    
    @discardableResult
    func fetchPhotos(page: Int, perPage: Int) -> Observable<[Photo]> {
        let endPoint = UnsplashEndPoint.photos(page: page, perPage: perPage)
        guard let url = endPoint.url else {
            return Observable.error(NetworkError.urlNotSupport)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        
        return urlSession.rx
            .data(request: request)
            .map { data -> [Photo] in
                let decoder = JSONDecoder()
                
                return try decoder.decode([Photo].self, from: data)
            }
            .catchAndReturn([])
        
    }
    
    @discardableResult
    func fetchSearchedPhotos(page: Int, perPage: Int, query: String) -> Observable<[Photo]> {
        guard let url = UnsplashEndPoint.searchPhotos(page: page, perPage: perPage, query: query).url else {
            return Observable.error(NetworkError.urlNotSupport)
        }
        
        let request = URLRequest(url: url)
        
        return urlSession.rx
            .data(request: request)
            .map { data -> [Photo] in
                let decoder = JSONDecoder()
                let searchedPhotos = try decoder.decode(SearchedPhoto.self, from: data)
                
                return searchedPhotos.results
            }
            .catchAndReturn([])
    }
    
    @discardableResult
    func fetchImage(endPoint: EndPointType) -> Observable<UIImage?> {
        guard let url = endPoint.url else {
            return Observable.error(NetworkError.urlNotSupport)
        }
        
        if let cachedImage = imageCache.object(forKey: url.lastPathComponent as NSString) {
            return Observable.just(cachedImage)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        
        return urlSession.rx
            .data(request: request)
            .map { UIImage(data: $0) }
            .catchAndReturn(nil)
    }
    
    func removeCache() {
        imageCache.removeAllObjects()
    }
    
}

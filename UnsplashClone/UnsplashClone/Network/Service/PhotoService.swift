//
//  PhotoService.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/16.
//

import Foundation

final class PhotoService: PhotoServicing {
    
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, NetworkError>) -> Void) {
        request(dataType: Photo.self, endPoint: UnsplashEndPoint.photo(id: id)) { result in
            completion(result)
        }
    }
    
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        request(dataType: [Photo].self, endPoint: UnsplashEndPoint.photos(page: page, perPage: perPage)) { result in
            completion(result)
        }
    }
    
    func fetchSearchedPhotos(page: Int, perPage: Int, query: String, completion: @escaping (Result<SearchedPhoto, NetworkError>) -> Void) {
        request(dataType: SearchedPhoto.self, endPoint: UnsplashEndPoint.searchPhotos(page: page, perPage: perPage, query: query)) { result in
            completion(result)
        }
    }
    
    func fetchRandomPhoto(completion: @escaping (Result<Photo, NetworkError>) -> Void) {
        request(dataType: Photo.self, endPoint: UnsplashEndPoint.randomPhoto) { result in
            completion(result)
        }
    }
}

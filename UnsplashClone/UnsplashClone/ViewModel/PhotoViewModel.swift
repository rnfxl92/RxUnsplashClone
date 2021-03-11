//
//  PhotoViewModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/21.
//

import UIKit

class PhotoViewModel {
    
    let sceneCoordinator: SceneCoordinatorType
    let photoService: PhotoServicing
    let imageService: ImageServicing
    let photoData: Box<[Photo]> = Box([])
    let searchedPhotoData: Box<[Photo]> = Box([])
    let headerPhoto: Box<Photo?> = Box(nil)
    private var lastQuery = ""
    
    init(sceneCoordinator: SceneCoordinator, photoService: PhotoServicing, imageService: ImageServicing) {
        self.sceneCoordinator = sceneCoordinator
        self.photoService = photoService
        self.imageService = imageService
    }
    
    func fetchPhotoData(page: Int, perPage: Int) {
        photoService.fetchPhotos(page: page, perPage: perPage) {[weak self] result in
            switch result {
            case .success(let photos):
                self?.photoData.appendValue(photos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchSearchedPhotoData(page: Int, perPage: Int, query: String) {
        photoService.fetchSearchedPhotos(page: page, perPage: perPage, query: query) { [weak self] result in
            switch result {
            case .success(let photos):
                if self?.lastQuery == query {
                    self?.searchedPhotoData.appendValue(photos.results)
                } else {
                    self?.searchedPhotoData.value = photos.results
                }
                self?.lastQuery = query
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchImage(url: String, width: Int, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        let endPoint = UnsplashEndPoint.photoURL(url: url, width: width)
        imageService.imageURL(endPoint: endPoint, completion: completion)
    }
    
    func fetchHeaderPhoto() {
        photoService.fetchRandomPhoto { [weak self] result in
            switch result {
            case .success(let photo):
                self?.headerPhoto.value = photo
            case .failure(let error):
                print(error)
            }
        }
    }
}

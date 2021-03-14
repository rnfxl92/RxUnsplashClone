//
//  DetailViewModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/14.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxDataSources

class DetailViewModel {
    
    let sceneCoordinator: SceneCoordinatorType
    let photoService: PhotoServicing
    let imageService: ImageServicing
    let photoData: Box<[Photo]> = Box([])
    let searchedPhotoData: Box<[Photo]> = Box([])
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
    
}

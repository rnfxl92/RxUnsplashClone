//
//  RxPhotoViewModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/14.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import Action

typealias SectionModel = AnimatableSectionModel<Int, Photo>

class RxPhotoViewModel: CommonViewModel, HasDisposeBag {
    var photoList = [Photo]()
    var searchedPhotoList = [Photo]()
    private var lastQuery = ""
    lazy var headerPhoto = photoApi.fetchRandomPhoto()
    lazy var photoData = BehaviorSubject<[SectionModel]>(value: [SectionModel(model: 0, items: photoList)])
    lazy var searchedPhotoData = BehaviorSubject<[SectionModel]>(value: [SectionModel(model: 0, items: searchedPhotoList)])

    let tableViewDataSource: RxTableViewSectionedAnimatedDataSource<SectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { (dataSource, tableView, indexPath, photo) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.Identifier.reusableCell, for: indexPath) as? PhotoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configureCell(username: photo.username, sponsored: photo.sponsored, imageSize: cell.frame.size)
            
            return cell
        })

        return ds
    }()
    
    let collectionViewDataSource: RxCollectionViewSectionedAnimatedDataSource<SectionModel> = {
        let ds = RxCollectionViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { (dataSource, collectionView, indexPath, photo) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.Identifier.reusableCell, for: indexPath) as? DetailCollectionViewCell else {
                return UICollectionViewCell()
            }
                            
                return cell
        })

        return ds
    }()
    
    func fetchPhotoData(page: Int, perPage: Int) {
        photoApi.fetchPhotos(page: page, perPage: perPage)
            .subscribe(onNext: { [unowned self] photos in
                self.photoList.append(contentsOf: photos)
                let sectionModel = SectionModel(model: 0, items: self.photoList)
                self.photoData.onNext([sectionModel])
            })
            .disposed(by: rx.disposeBag)
    }
    
    func fetchSearchedPhotoData(page: Int, perPage: Int, query: String) {
       photoApi.fetchSearchedPhotos(page: page, perPage: perPage, query: query)
        .subscribe(onNext: { [unowned self] searchedPhotos in
            if query == self.lastQuery {
                self.searchedPhotoList.append(contentsOf: searchedPhotos)
            } else {
                self.lastQuery = query
                self.searchedPhotoList = searchedPhotos
            }
            
            let sectionModel = SectionModel(model: 0, items: self.searchedPhotoList)
            self.searchedPhotoData.onNext([sectionModel])
        })
        .disposed(by: rx.disposeBag)
    }

    func fetchImage(url: String, width: Int) -> Observable<UIImage?> {
        let endPoint = UnsplashEndPoint.photoURL(url: url, width: width)
        return photoApi.fetchImage(endPoint: endPoint)
    }
    
    lazy var closeAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.close(animated: true).asObservable().map { _ in }
    }
    
}

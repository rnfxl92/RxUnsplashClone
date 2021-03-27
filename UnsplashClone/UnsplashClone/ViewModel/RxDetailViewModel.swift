//
//  RxDetailViewModel.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/03/24.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxDataSources
import NSObject_Rx

class RxDetailViewModel: CommonViewModel, HasDisposeBag {
    var photoList = [Photo]()
    private var query: String?
    lazy var photoData = BehaviorSubject<[SectionModel]>(value: [SectionModel(model: 0, items: photoList)])
    
    init(sceneCoordinator: SceneCoordinatorType, photoApi: PhotoApiType, photoList: [Photo], query: String? = nil) {
        self.photoList = photoList
        self.query = query
        
        super.init(sceneCoordinator: sceneCoordinator, photoApi: photoApi)
    }
    
    let dataSource: RxCollectionViewSectionedAnimatedDataSource<SectionModel> = {
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
    
    func fetchSearchedPhotoData(page: Int, perPage: Int) {
        guard let query = query else {
            return
        }
       photoApi.fetchSearchedPhotos(page: page, perPage: perPage, query: query)
        .subscribe(onNext: { [unowned self] searchedPhotos in
            self.photoList.append(contentsOf: searchedPhotos)
            let sectionModel = SectionModel(model: 0, items: self.photoList)
            
            self.photoData.onNext([sectionModel])
        })
        .disposed(by: rx.disposeBag)
    }

    func fetchImage(url: String, width: Int) -> Observable<UIImage?> {
        let endPoint = UnsplashEndPoint.photoURL(url: url, width: width)
        return photoApi.fetchImage(endPoint: endPoint)
    }
    
    lazy var closeAction = CocoaAction { [unowned self] in
        // TODO: - 닫고나서 photoList 처리하기
        return self.sceneCoordinator.close(animated: true).asObservable().map { _ in }
    }
    
}

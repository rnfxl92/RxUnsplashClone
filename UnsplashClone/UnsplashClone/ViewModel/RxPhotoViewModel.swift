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

typealias SectionModel = AnimatableSectionModel<Int, Photo>

class RxPhotoViewModel: CommonViewModel, HasDisposeBag {
    private var photoList = [Photo]()
    private var searchedPhotoList = [Photo]()
    private var lastQuery = ""
    lazy var headerPhoto = photoApi.fetchRandomPhoto()
    var photoData = PublishSubject<[SectionModel]>()

    let dataSource: RxTableViewSectionedAnimatedDataSource<SectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SectionModel>(configureCell: { (dataSource, tableView, indexPath, photo) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.Identifier.reusableCell, for: indexPath) as? PhotoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configureCell(username: photo.username, sponsored: photo.sponsored, imageSize: cell.frame.size)
            
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
    
    func fetchSearchedPhotoData(page: Int, perPage: Int, query: String) -> Driver<[SectionModel]> {
        return photoApi.fetchSearchedPhotos(page: page, perPage: perPage, query: query)
            .asDriver(onErrorJustReturn: [Photo]())
            .map { [unowned self] searchedPhotos in
                if lastQuery == query {
                self.searchedPhotoList.append(contentsOf: searchedPhotos)
                } else {
                    self.searchedPhotoList = searchedPhotos
                }
                
                return [SectionModel(model: 0, items: self.searchedPhotoList)]
            }
            .asDriver(onErrorJustReturn: [])
    }

    func fetchImage(url: String, width: Int) -> Observable<UIImage?> {
        
        let endPoint = UnsplashEndPoint.photoURL(url: url, width: width)
        
        return photoApi.fetchImage(endPoint: endPoint)
    }
}

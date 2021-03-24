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
    private var photoList: [Photo]
    private let isSearch: Bool
    private let query: String
    
    init(sceneCoordinator: SceneCoordinatorType, photoApi: PhotoApiType, photoList: [Photo], isSearch: Bool, query: String = "") {
        self.photoList = photoList
        self.isSearch = isSearch
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
    
    lazy var closeAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.close(animated: true).asObservable().map { _ in }
    }
    
    
}

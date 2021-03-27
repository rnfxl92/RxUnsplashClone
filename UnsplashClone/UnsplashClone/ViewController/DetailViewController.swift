//
//  DetailViewController.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/26.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class DetailViewController: UIViewController, ViewModelBindableType {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationTitleItem: UINavigationItem!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    weak var coordinator: SceneCoordinatorType?
    var viewModel: RxDetailViewModel!
    var defaultIndexPath: IndexPath?
    var firstCall: Bool = true
    var query: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureTransparentNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if firstCall {
            //scrollToDefaultPhoto()
        }
    }
    

    func bindViewModel() {
        
        if query != nil && query != "" {
        }
        
        viewModel.photoData
            .asDriver(onErrorJustReturn: [])
            .drive(detailCollectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        closeButton.rx.action = viewModel.closeAction
        
    }
    
//    func scrollToDefaultPhoto() {
//        guard let defaultIndexPath = defaultIndexPath,
//              let photo = dataSource.itemIdentifier(for: defaultIndexPath) else {
//            return
//        }
//
//        detailCollectionView.scrollToItem(at: defaultIndexPath, at: .left, animated: false)
//        navigationTitleItem.title = photo.username
//        firstCall = false
//    }
    
    private func configureCollectionView() {
        detailCollectionView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        
    }
    
    private func configureTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        coordinator?.close(animated: true)
    }
    
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: detailCollectionView.frame.width, height: detailCollectionView.frame.height)
    }
}

extension DetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = viewModel.dataSource.sectionModels[0].items.count
        
        if indexPath.item == itemCount - 1 {
            let page = Int(ceil(Double(itemCount) / Double(CommonValues.perPage))) + 1
            if query != nil {
                viewModel.fetchSearchedPhotoData(page: page, perPage: CommonValues.perPage)
            } else {
                viewModel.fetchPhotoData(page: page, perPage: CommonValues.perPage)
            }
            
        }
        
        let photo = viewModel.dataSource[indexPath]
        guard let photoCell = cell as? DetailCollectionViewCell else {
            return
        }

        let width = Int(collectionView.frame.width)

        viewModel.fetchImage(url: photo.photoURLs.full, width: width)
            .asDriver(onErrorJustReturn: nil)
            .drive(photoCell.photoImageView.rx.image)
            .disposed(by: rx.disposeBag)
    }
}

//extension DetailViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let visibleIndexPath = detailCollectionView.visibleIndexPath else {
//            return
//        }
//
//        navigationTitleItem.title = dataSource.itemIdentifier(for: visibleIndexPath)?.username ?? ""
//    }
//}

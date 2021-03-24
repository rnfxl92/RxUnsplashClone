//
//  ViewController.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: RxPhotoViewModel!
    private lazy var photoTableHeaderHeight: CGFloat = view.frame.height / 3
    private var headerView: UIView!
    var isSearch: Bool = false
    
    @IBOutlet weak var photoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableVeiw()
        searchBar.delegate = self
    }
    
    func bindViewModel() {
        
        viewModel.photoData
            .asDriver(onErrorJustReturn: [])
            .drive(photoTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.fetchPhotoData(page: 0, perPage: CommonValues.perPage)
        
        guard let headerView = headerView as? PhotoTableViewHeaderView else {
            return
        }
        
        viewModel.headerPhoto
            .map {
                $0?.username
            }.bind(to: headerView.userLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.headerPhoto
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] photo in
                guard let photo = photo else {
                    return
                }
                headerView.configureUserLabel(username: photo.username)
                
                let width = Int(self.photoTableView.frame.width * UIScreen.main.scale)
                
                self.viewModel.fetchImage(url: photo.photoURLs.regular, width: width)
                    .bind(to: headerView.headerImageView.rx.image)
                    .disposed(by: rx.disposeBag)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func configureTableVeiw() {
        PhotoTableViewCell.registerNib(tableView: photoTableView)
        
        photoTableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        photoTableView.rowHeight =
            UITableView.automaticDimension
        
        headerView = photoTableView.tableHeaderView
        photoTableView.tableHeaderView = nil
        photoTableView.addSubview(headerView)
        photoTableView.contentInset = UIEdgeInsets(top: photoTableHeaderHeight, left: 0, bottom: 0, right: 0)
        photoTableView.contentOffset = CGPoint(x: 0, y: -photoTableHeaderHeight)
        
        updateHeaderView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeKeypad))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func removeKeypad() {
        searchBar.resignFirstResponder()
    }
    
}

extension PhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = viewModel.dataSource[indexPath]
        
        let width = tableView.frame.width
        let ratio = CGFloat(photo.height) / CGFloat(photo.width)
        
        return width * ratio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearch {
            let detailViewModel = RxDetailViewModel(
                sceneCoordinator: viewModel.sceneCoordinator,
                photoApi: viewModel.photoApi,
                photoList: viewModel.searchedPhotoList,
                query: searchBar.text)
            let detailScene = Scene.detail(detailViewModel, indexPath, searchBar.text)
            
            viewModel.sceneCoordinator.transition(to: detailScene, using: .modal, animated: true)
        } else {
            let detailViewModel = RxDetailViewModel(
                sceneCoordinator: viewModel.sceneCoordinator,
                photoApi: viewModel.photoApi,
                photoList: viewModel.photoList
                )
            let detailScene = Scene.detail(detailViewModel, indexPath, nil)
            
            viewModel.sceneCoordinator.transition(to: detailScene, using: .modal, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemCount = viewModel.dataSource.sectionModels[0].items.count
        if indexPath.item == itemCount - 1 {
            let page = Int(ceil(Double(itemCount) / Double(CommonValues.perPage))) + 1
            if let text = searchBar.text,
               isSearch {
                viewModel.fetchSearchedPhotoData(page: page, perPage: CommonValues.perPage, query: text)
            } else {
                viewModel.fetchPhotoData(page: page, perPage: CommonValues.perPage)
            }
        }
        
        let photo = viewModel.dataSource[indexPath]
        guard let photoCell = cell as? PhotoTableViewCell else {
            return
        }
        
        let width = Int(tableView.frame.width * UIScreen.main.scale)
        
        viewModel.fetchImage(url: photo.photoURLs.regular, width: width)
            .asDriver(onErrorJustReturn: nil)
            .drive(photoCell.photoImageView.rx.image)
            .disposed(by: rx.disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    /// tableView를 scroll하여 기본 .contentOffset.y가 photoTableHeaderHeight보다 더 내려갔으면 headerView height를 그만큼 늘려줌
    func updateHeaderView() {
        
        var headerRect = CGRect(x: 0, y: -photoTableHeaderHeight, width: photoTableView.bounds.width, height: photoTableHeaderHeight)
        if photoTableView.contentOffset.y < -photoTableHeaderHeight {
            headerRect.origin.y = photoTableView.contentOffset.y
            headerRect.size.height = -photoTableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
}

extension PhotoViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text,
              searchBarText != "" else {
            isSearch = false
            return
        }
        isSearch = true
        photoTableView.dataSource = nil
        viewModel.searchedPhotoData
            .asDriver(onErrorJustReturn: [])
            .drive(photoTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        viewModel.fetchSearchedPhotoData(page: 1, perPage: CommonValues.perPage, query: searchBarText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearch = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        photoTableView.dataSource = nil
        viewModel.photoData
            .asDriver(onErrorJustReturn: [])
            .drive(photoTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        photoTableView.reloadData()
    }
}

//
//  ViewController.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import UIKit
import RxSwift

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
        viewModel.fetchPhotoData(page: 0, perPage: CommonValues.perPage)
            .drive(photoTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
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
                
                let endPoint = UnsplashEndPoint.photoURL(url: photo.photoURLs.regular, width: Int(self.photoTableView.frame.width))
                
                self.viewModel.photoApi.fetchImage(endPoint: endPoint)
                    .bind(to: headerView.headerImageView.rx.image)
                    .disposed(by: rx.disposeBag)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func configureTableVeiw() {
        PhotoTableViewCell.registerNib(tableView: photoTableView)
        
        photoTableView.delegate = self
        photoTableView.rowHeight =
            UITableView.automaticDimension
        
        headerView = photoTableView.tableHeaderView
        photoTableView.tableHeaderView = nil
        photoTableView.addSubview(headerView)
        photoTableView.contentInset = UIEdgeInsets(top: photoTableHeaderHeight, left: 0, bottom: 0, right: 0)
        photoTableView.contentOffset = CGPoint(x: 0, y: -photoTableHeaderHeight)
        
        updateHeaderView()
        
    }
    
    
    @objc func removeKeypad() {
        searchBar.resignFirstResponder()
    }
    
}

extension PhotoViewController: UITableViewDelegate {
    

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

        viewModel.fetchSearchedPhotoData(page: 1, perPage: CommonValues.perPage, query: searchBarText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

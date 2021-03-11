//
//  ViewController.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import UIKit

final class PhotoViewController: UIViewController, ViewModelBindableType {
    
    private lazy var dataSource = createDataSource()
    
    weak var coordinator: SceneCoordinatorType?
    var viewModel: PhotoViewModel!
    private lazy var photoTableHeaderHeight: CGFloat = view.frame.height / 3
    private var headerView: UIView!
    var isSearch: Bool = false
    
    @IBOutlet weak var photoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        searchBar.delegate = self
    }
    
    func bindViewModel() {
        bindWithPhoto()
        
        viewModel.headerPhoto.bind { [weak self] photo in
            guard let self = self,
                  let photo = photo,
                  let headerView = self.headerView as? PhotoTableViewHeaderView
            else {
                return
            }
            
            DispatchQueue.main.async {
                headerView.configureUserLabel(username: photo.username)
                let width = Int(self.view.frame.width * UIScreen.main.scale)
                
                DispatchQueue.global().async {
                    self.viewModel.fetchImage(url: photo.photoURLs.regular, width: width) { result in
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                headerView.configureHeaderImage(image: image)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
        
        viewModel.fetchHeaderPhoto()
        viewModel.fetchPhotoData(page: 1, perPage: CommonValues.perPage)
    }
    
    private func configureTableView() {
        photoTableView.delegate = self
        photoTableView.rowHeight =
            UITableView.automaticDimension
        
        headerView = photoTableView.tableHeaderView
        photoTableView.tableHeaderView = nil
        photoTableView.addSubview(headerView)
        photoTableView.contentInset = UIEdgeInsets(top: photoTableHeaderHeight, left: 0, bottom: 0, right: 0)
        photoTableView.contentOffset = CGPoint(x: 0, y: -photoTableHeaderHeight)
        
        PhotoTableViewCell.registerNib(tableView: photoTableView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeKeypad))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        updateHeaderView()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }
    
    @objc func removeKeypad() {
        searchBar.resignFirstResponder()
    }
    
    func bindWithPhoto() {
        viewModel?.photoData.bind { [weak self] photos in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
            snapshot.appendSections([.main])
            snapshot.appendItems(photos)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot)
            }
        }
    }
    
    func bindWithSearchedPhoto() {
        viewModel?.searchedPhotoData.bind { [weak self] photos in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
            snapshot.appendSections([.main])
            snapshot.appendItems(photos)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot)
            }
        }
    }
}

extension PhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let photo = dataSource.itemIdentifier(for: indexPath)
        else {
            return .zero
        }
        
        let width = tableView.frame.width
        let ratio = CGFloat(photo.height) / CGFloat(photo.width)
        let height = width * ratio
        
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == dataSource.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            let page = Int(ceil(Double(dataSource.tableView(tableView, numberOfRowsInSection: 0)) / Double(CommonValues.perPage))) + 1
            if (searchBar.text != nil) && isSearch {
                viewModel.fetchSearchedPhotoData(page: page, perPage: CommonValues.perPage, query: searchBar.text!)
            } else {
                viewModel.fetchPhotoData(page: page, perPage: CommonValues.perPage)
            }
        }
        
        guard let photoCell = cell as? PhotoTableViewCell,
              let photo = dataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        let width = Int(view.frame.width * UIScreen.main.scale)
        viewModel.fetchImage(url: photo.photoURLs.regular, width: width) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    photoCell.configureCell(image: image)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailScene = Scene.detail(viewModel, indexPath, searchBar.text)
        
        coordinator?.transition(to: detailScene, using: .modal, animated: true)
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

extension PhotoViewController {
    func createDataSource() -> PhotoTableViewDataSource {
        let dataSource = PhotoTableViewDataSource(
            tableView: photoTableView,
            cellProvider: { (tableView, indexPath, photo) -> UITableViewCell? in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.Identifier.reusableCell, for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
                
                cell.configureCell(username: photo.username, sponsored: photo.sponsored, imageSize: cell.frame.size)
                return cell
            }
        )
        return dataSource
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
        bindWithSearchedPhoto()
        viewModel.fetchSearchedPhotoData(page: 1, perPage: CommonValues.perPage, query: searchBarText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        searchBar.text = ""
        bindWithPhoto()
        searchBar.resignFirstResponder()
    }
}

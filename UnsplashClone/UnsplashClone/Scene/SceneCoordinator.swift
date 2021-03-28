//
//  SceneCoordinator.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
}

class SceneCoordinator: SceneCoordinatorType {
    
    private let bag = DisposeBag()
    
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TranstionStyle, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        
        let target = scene.instantiate(sceneCoordinator: self)
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
        case .push:
            guard let nav = currentVC.navigationController
            else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            nav.rx.willShow
                .subscribe(onNext: { [unowned self] evt in
                    self.currentVC = evt.viewController.sceneViewController
                }).disposed(by: bag)
            currentVC = target.sceneViewController
            
            subject.onCompleted()
        case .modal:
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
        }
        
        return subject.ignoreElements().asCompletable()
    }
    
        @discardableResult
        func close(animated: Bool) -> Completable {
            return Completable.create { [unowned self] completable in
                if let presentingVC = self.currentVC.presentingViewController {
                    guard let detailVC = currentVC as? DetailViewController else {
                        self.currentVC.dismiss(animated: animated)
                        completable(.completed)
                        return Disposables.create()
                    }
                    
                    let indexPath = detailVC.detailCollectionView.visibleIndexPath
                    let photoList = detailVC.viewModel.photoList
                    self.currentVC.dismiss(animated: animated) {
                        self.currentVC = presentingVC.sceneViewController
                        if let vc = currentVC as? PhotoViewController {
                            if vc.isSearch {
                                vc.viewModel.searchedPhotoList = photoList
                                vc.viewModel.searchedPhotoData
                                    .onNext([SectionModel(model: 0, items: vc.viewModel.searchedPhotoList)])
                            } else {
                                vc.viewModel.photoList = photoList
                                vc.viewModel.photoData
                                    .onNext([SectionModel(model: 0, items: vc.viewModel.photoList)])
                            }
                            if let indexPath = indexPath {
                                vc.photoTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
    
                        completable(.completed)
                    }
                } else if let nav = self.currentVC.navigationController {
                    guard nav.popViewController(animated: animated) != nil else {
                        completable(.error(TransitionError.cannotPop))
                        return Disposables.create()
                    }
    
                    self.currentVC = nav.viewControllers.last!
    
                    completable(.completed)
                } else {
                    completable(.error(TransitionError.unknown))
                }
    
                return Disposables.create()
            }
        }
}

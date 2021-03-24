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
    
    // TODO: - 추가 ViewModel 만들고 Action으로 close를 연결하자
    
    
        @discardableResult
        func close(animated: Bool) -> Completable {
            return Completable.create { [unowned self] completable in
                if let presentingVC = self.currentVC.presentingViewController {
                    let indexPath: IndexPath? = {
                        if let vc = currentVC as? DetailViewController {
                            return vc.detailCollectionView.visibleIndexPath
                        }
                        return nil
                    }()
    
                    self.currentVC.dismiss(animated: animated) {
                        self.currentVC = presentingVC.sceneViewController
    
                        if let vc = currentVC as? PhotoViewController {
                            
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
    
//    func close(animated: Bool) {
//        if let presentingVC = currentVC.presentingViewController {
//            let indexPath: IndexPath? = {
//                if let vc = currentVC as? DetailViewController {
//                    return vc.detailCollectionView.visibleIndexPath
//                }
//                return nil
//            }()
//
//            currentVC.dismiss(animated: animated) { [unowned self] in
//                self.currentVC = presentingVC.sceneViewController
//                if let vc = currentVC as? PhotoViewController {
//                    if vc.isSearch {
//                        //vc.bindWithSearchedPhoto()
//                    } else {
//                        //vc.bindWithPhoto()
//                    }
//                    if let indexPath = indexPath {
//                        vc.photoTableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                    }
//                }
//            }
//        } else if let nav = currentVC.navigationController {
//            guard nav.popViewController(animated: animated) != nil else {
//                print(TransitionError.navigationControllerMissing)
//                return
//            }
//            currentVC = nav.viewControllers.last!
//        } else {
//            print("error")
//        }
//    }
//
//}

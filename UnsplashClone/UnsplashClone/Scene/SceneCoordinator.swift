//
//  SceneCoordinator.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import UIKit

extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
}

class SceneCoordinator: SceneCoordinatorType {
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    func transition(to scene: Scene, using style: TranstionStyle, animated: Bool) {
        let target = scene.instantiate(sceneCoordinator: self)
        switch style {
        case .root:
           currentVC = target.sceneViewController
           window.rootViewController = target
        case .push:
           print(currentVC)
           guard let nav = currentVC.navigationController else {
              print("nav error")
              break
           }
           nav.pushViewController(target, animated: animated)
           currentVC = target.sceneViewController
        case .modal:
           currentVC.present(target, animated: animated)
           currentVC = target.sceneViewController
        }
        
    }
    
    func close(animated: Bool) {
        if let presentingVC = currentVC.presentingViewController {
            let indexPath: IndexPath? = {
                if let vc = currentVC as? DetailViewController {
                    return vc.detailCollectionView.visibleIndexPath
                }
                return nil
            }()
            
            currentVC.dismiss(animated: animated) { [unowned self] in
                self.currentVC = presentingVC.sceneViewController
                if let vc = currentVC as? PhotoViewController {
                    if vc.isSearch {
                        vc.bindWithSearchedPhoto()
                    } else {
                        vc.bindWithPhoto()
                    }
                    if let indexPath = indexPath {
                        vc.photoTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        } else if let nav = currentVC.navigationController {
            guard nav.popViewController(animated: animated) != nil else {
                print(TransitionError.navigationControllerMissing)
                return
            }
            currentVC = nav.viewControllers.last!
        } else {
            print("error")
        }
    }
    
}

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

typealias PhotoSectionModel = AnimatableSectionModel<Int, Photo>

class RxPhotoViewModel: CommonViewModel {
    let dataSource: RxTableViewSectionedAnimatedDataSource<PhotoSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<PhotoSectionModel>(configureCell: { (dataSource, tableView, indexPath, photo) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.Identifier.reusableCell, for: indexPath) as? PhotoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configureCell(username: photo.username, sponsored: photo.sponsored, imageSize: cell.frame.size)
            
            return cell
        })
        
        ds.canEditRowAtIndexPath = { _, _ in
            return true
        }
        return ds
    }()
    
    //TODO: - Action 및 datasource에 api 요청을 통해 photo 추가하기
}

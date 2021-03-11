//
//  DataSource.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/26.
//

import UIKit

typealias PhotoTableViewDataSource = UITableViewDiffableDataSource<Section, Photo>
typealias PhotoCollectionViewDataSource = UICollectionViewDiffableDataSource<Section, Photo>

enum Section: Hashable {
    case main
}

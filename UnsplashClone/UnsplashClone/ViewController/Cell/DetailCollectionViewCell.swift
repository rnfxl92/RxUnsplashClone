//
//  DetailCollectionViewCell.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/26.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
 
    func configureImage(image: UIImage?) {
        photoImageView.image = image

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
}

extension DetailCollectionViewCell {
    
    enum Identifier {
        static let reusableCell: String = "DetailCell"
    }
    
    enum Name {
        static let typeName: String = "DetailCollectionViewCell"
    }
}

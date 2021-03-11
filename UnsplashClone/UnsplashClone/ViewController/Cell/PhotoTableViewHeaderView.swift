//
//  PhotoTableViewHeaderView.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/19.
//

import UIKit

class PhotoTableViewHeaderView: UIView {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    func configureHeaderImage(image: UIImage?) {
        headerImageView.image = image
    }
    
    func configureUserLabel(username: String) {
        userLabel.text = "Photo of the Day by " + username
    }
}

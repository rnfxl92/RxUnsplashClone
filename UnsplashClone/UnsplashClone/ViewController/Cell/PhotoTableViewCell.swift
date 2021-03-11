//
//  PhotoTableViewCell.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/19.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = photoImageView.makeGradientLayer()
    }
    
    func configureCell(username: String, sponsored: Bool, imageSize: CGSize) {
        usernameLabel.text = username
        sponsoredLabel.isHidden = !sponsored
        gradientLayer?.frame.size = imageSize
    }
    
    func configureCell(image: UIImage?) {
          photoImageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
}

extension PhotoTableViewCell {
    static func registerNib(tableView: UITableView) {
        let nib = UINib(nibName: PhotoTableViewCell.Name.typeName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Identifier.reusableCell)
    }
}

extension PhotoTableViewCell {
    
    enum Identifier {
        static let reusableCell: String = "PhotoCell"
    }
    
    enum Name {
        static let typeName: String = "PhotoTableViewCell"
    }
}

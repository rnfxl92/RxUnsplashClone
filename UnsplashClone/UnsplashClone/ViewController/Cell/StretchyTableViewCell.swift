//
//  StretchyTableViewCell.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/19.
//

import UIKit

class StretchyTableViewCell: UITableViewCell {

    let view1: UIView = {
        let vie = UIView()
        vie.translatesAutoresizingMaskIntoConstraints = false
        vie.backgroundColor = .black
        return vie
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUpUI() {
        self.backgroundColor = .white
        
        view1.layer.cornerRadius = 10.0
        self.addSubview(view1)
        
        view1.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        view1.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        view1.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        view1.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true

    }
}

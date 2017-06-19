//
//  SettingCell.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/8/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit


var resizeImage = ResizingImage()

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    func setupView() {
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class SettingCell: BaseCell {
    
    
override var isHighlighted: Bool {
    didSet {
        backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
        nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
            
    }
}
    
    
var setting: Settings? {
    didSet {
        nameLabel.text = setting?.name.rawValue
        
        if let imageName = setting?.imageName {
            iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor.darkGray
            
        }
    }
}
    
        
let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Setting"
    label.font = UIFont.systemFont(ofSize: 14)
    return label
}()
        
        
let iconImageView: UIImageView = {
    let imageView = UIImageView()
    //let newImage = resizeImage.resizeImageWith(image: UIImage(named: "Setting")!,newSize: CGSize(width: 45, height: 45))
    imageView.image = UIImage(named: "Setting")
    
    imageView.contentMode = .scaleAspectFit
    return imageView
}()
        
override func setupView() {
    super.setupView()
        
    addSubview(nameLabel)
    self.addSubview(iconImageView)
    addConstraintsWithFormat(format: "H:|-8-[v0(30)]-8-[v1]|", views: iconImageView,nameLabel)
        
        
    addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        
    addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
    
    addConstraint(NSLayoutConstraint(item: iconImageView, attribute:.centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
    


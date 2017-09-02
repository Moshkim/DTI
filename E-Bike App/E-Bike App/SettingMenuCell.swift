//
//  SettingMenuCell.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/1/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit
class SettingMenuCell: UICollectionViewCell {
    
    let settingLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.text = "Settings"
        label.textColor = UIColor.white
        return label
    }()
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(settingLabel)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: settingLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: settingLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

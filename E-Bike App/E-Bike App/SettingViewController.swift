//
//  SettingViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/2/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit


class SettingViewController: UIViewController{


    lazy var backToHome: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("<Back", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.isHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(moveBack), for: .touchUpInside)
        return button
    }()
    
    
    func moveBack() {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(backToHome)
        
        _ = backToHome.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 30)
        
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
    }

}

//
//  LoginPage.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/13/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit

class LoginPage: UICollectionViewCell {

    
    let logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageClicked = UIImage(named: "logoClicked")
        let imageView = UIImageView(image: image)
        
        
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let text = LeftPaddingTextField()
        text.placeholder = "Enter Email"
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.layer.borderWidth = 1
        text.keyboardType = .emailAddress
        return text
        
    }()
    
    let passwordTextField: UITextField = {
        let password = LeftPaddingTextField()
        password.placeholder = "Enter Password"
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.layer.borderWidth = 1
        password.isSecureTextEntry = true
        return password
        
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        //let Text = NSMutableAttributedString(string: "Log In", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 10), NSForegroundColorAttributeName:UIColor.DTIRed()])
        button.backgroundColor = UIColor.DTIBlue()
        
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor.DTIRed(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.shadowColor = UIColor.darkGray
        //button.isHighlighted = true
        //button.adjustsImageWhenHighlighted = true
        
        return button
    }()
    
    

    
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoImageView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        //addSubview(moveToMapButton)
        
        
        _ = logoImageView.anchor(centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: -200, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = emailTextField.anchor(logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        _ = loginButton.anchor(passwordTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        //_ = moveToMapButton.anchor(loginButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 30)
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class LeftPaddingTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
    
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }

}

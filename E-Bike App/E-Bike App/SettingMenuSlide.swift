//
//  SettingMenuSlide.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/1/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingMenuSlide: NSObject {
    
    var rideStatusView: RiderStatusViewController?
    let windowSize = UIApplication.shared.keyWindow
    
    lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.4)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DismissMenuBar)))
    
        return view
    }()
    
    let slideMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return view
    }()
    
    
    let profilePicture: UIImageView = {
        
         let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Decode the saved profile picture
        
        let image = UserDefaults.standard.object(forKey: "profileImage")
        if let profileImage = image {
        
            imageView.image = UIImage(data: (image as! NSData) as Data)
        } else {
            imageView.image = UIImage(named: "profile")
        
        }
       
        
        imageView.backgroundColor = UIColor.clear
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    // MARK - PROFILE USERNAME 
    
    //*************************************************************************************************************************************//
    let profileNickName: UILabel = {
        let label = UILabel()
        if let username = UserDefaults.standard.object(forKey: "username") {
            label.text = "\(username)"
        
        } else {
            label.text = "Burning Bush"
        }
        
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false

        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 40, width: (((UIApplication.shared.keyWindow?.frame.width)!/3)*2), height: 0.6)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        //label.layer.addSublayer(bottomLayer)
        
        return label
    }()
    
    //*************************************************************************************************************************************//
    
    
    // MARK - TERMS AND PRIVACY
    //*************************************************************************************************************************************//
    
    lazy var termsAndPrivacy: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("Terms & Privacy", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(moveToTermsAndPrivacyViewController), for: .touchUpInside)
        return button
    }()
    
    
    func moveToTermsAndPrivacyViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow{
                self.slideMenuView.frame = CGRect(x: -((window.frame.width/3)*2), y: 0, width: (window.frame.width/3)*2, height: window.frame.height)
                
            }
        }, completion: {(completed: Bool) in
            // going to setting view controller to set the setting
            self.rideStatusView?.showControllerWithTermsAndPrivacyButton()
            
        })
    }
    
    //*************************************************************************************************************************************//
    
    
    // MARK - USER SETTINGS
    
    //*************************************************************************************************************************************//
    let settingImage: UIImageView = {
        let image = UIImage(named: "setting")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.white
        return imageView
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("Settings", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(moveToSettingViewController), for: .touchUpInside)
        return button
    
    }()
    
    func moveToSettingViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow{
                self.slideMenuView.frame = CGRect(x: -((window.frame.width/3)*2), y: 0, width: (window.frame.width/3)*2, height: window.frame.height)
                
            }
        }, completion: {(completed: Bool) in
            // going to setting view controller to set the setting
            self.rideStatusView?.showControllerWithSettingButton()
            
        })
    
    }
    //*************************************************************************************************************************************//
    
    
    
    
    // MARK - LOG OUT 
    //*************************************************************************************************************************************//
    lazy var logoutButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        button.backgroundColor = UIColor.clear
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(UIColor.DTIRed(), for: .normal)
        button.isHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        return button
        
    }()
    
    func logoutAction() {
        
        
        do {
            try Auth.auth().signOut()
            
        }   catch let logoutError {
            print("log out error", logoutError.localizedDescription)
            
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow{
                self.slideMenuView.frame = CGRect(x: -((window.frame.width/3)*2), y: 0, width: (window.frame.width/3)*2, height: window.frame.height)
                
            }
            
        
        }, completion: {(completed: Bool) in
            // going back to login page once we are sign out
            self.rideStatusView?.showControllerWithLogoutButton()
        
        })
        
        
    }
    
    
    //*************************************************************************************************************************************//
    
    
    
    // MARK - CENTER FUNCTION TO HANDLING ALL THE SIDE MENU UI
    
    //*************************************************************************************************************************************//
    func handleSideMenuButton() {
        
        //Show Menu
        
        
        if let window = UIApplication.shared.keyWindow{

            
            window.addSubview(blackView)
            window.addSubview(slideMenuView)
            slideMenuView.addSubview(profilePicture)
            slideMenuView.addSubview(profileNickName)
            
            
            slideMenuView.addSubview(termsAndPrivacy)
            
            
            slideMenuView.addSubview(settingImage)
            slideMenuView.addSubview(settingButton)
            slideMenuView.addSubview(logoutButton)
            
            
            let x = (window.frame.width/3)*2
            slideMenuView.frame = CGRect(x: -x, y: 0, width: (window.frame.width/3)*2, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            _ = profilePicture.anchor(slideMenuView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
                profilePicture.centerXAnchor.constraint(equalTo: slideMenuView.centerXAnchor).isActive = true
            
            _ = profileNickName.anchor(profilePicture.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: slideMenuView.frame.width, heightConstant: 40)
                profileNickName.centerXAnchor.constraint(equalTo: slideMenuView.centerXAnchor).isActive = true
            
            
            
            _ = termsAndPrivacy.anchor(nil, left: nil, bottom: settingButton.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 30, rightConstant: 0, widthConstant: 90, heightConstant: 30)
                termsAndPrivacy.centerXAnchor.constraint(equalTo: slideMenuView.centerXAnchor).isActive = true
            
            
            _ = settingImage.anchor(nil, left: slideMenuView.leftAnchor, bottom: logoutButton.topAnchor, right: settingButton.leftAnchor, topConstant: 0, leftConstant: 40, bottomConstant: 80, rightConstant: 0, widthConstant: 30, heightConstant: 30)
            
            _ = settingButton.anchor(nil, left: nil, bottom: logoutButton.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 80, rightConstant: 0, widthConstant: 90, heightConstant: 30)
                settingButton.centerXAnchor.constraint(equalTo: slideMenuView.centerXAnchor).isActive = true
            
            _ = logoutButton.anchor(nil, left: nil, bottom: slideMenuView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: slideMenuView.frame.width, heightConstant: 40)
                logoutButton.centerXAnchor.constraint(equalTo: slideMenuView.centerXAnchor).isActive = true
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                self.slideMenuView.frame = CGRect(x: 0, y: 0, width: x, height: window.frame.height)
                
            }, completion: nil)
            
        }
    }
    
    //*************************************************************************************************************************************//
    
    
    
    func DismissMenuBar() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow{
                self.slideMenuView.frame = CGRect(x: -((window.frame.width/3)*2), y: 0, width: (window.frame.width/3)*2, height: window.frame.height)
                
            }
        }, completion: nil)
    }

    override init() {
        super.init()
        
        
        
    }
}

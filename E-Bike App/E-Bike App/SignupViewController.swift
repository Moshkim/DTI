//
//  Signup.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/20/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    
    
    
    let wholeView: UIImageView = {
        let image = UIImage(named: "signupBackground")
        let imageView = UIImageView(image: image)
        //imageView.center =
        imageView.frame(forAlignmentRect: .zero)
        imageView.layer.zPosition = -2
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }()
    
    let signUpNameTextField: UITextField = {
        let name = LeftPaddingTextField()
        name.placeholder = "Enter Your Nikname"
        name.borderStyle = UITextBorderStyle.roundedRect
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.darkGray.cgColor
        return name
    }()
    /*
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        button.addTarget(self, action: #selector(moveBackToLogin), for: .touchUpInside)
        return button
    }()
    
    func moveBackToLogin() {
    
    }*/
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 20.0
        button.backgroundColor = UIColor.DTIBlue()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(UIColor.DTIRed(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.addTarget(self, action: #selector(moveToMapView), for: .touchUpInside)
        return button
    }()
    
    func moveToMapView() {
    
        //let detinationVC = MapViewController()
        
        //self.present(detinationVC, animated: true, completion: nil)
        
        UserDefaults.standard.set(signUpNameTextField.text, forKey: "name")
        self.performSegue(withIdentifier: "MenuViewSegue", sender: continueButton)
    
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignupViewSegue" {
            let vc = segue.destination as! MenuViewController
        }
        
    }
    */
    /*
    let SignUpButton: UIButton = {
        let button = UIButton
    
    }
    */
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let blurrEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurrEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        let blurrView = UIVisualEffectView(effect: blurrEffect)
        
        blurrView.frame = view.bounds
        blurrView.layer.zPosition = -1
        blurrView.contentMode = .scaleAspectFit
        blurrView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurrView)
        view.addSubview(vibrancyView)
        view.addSubview(wholeView)
        
        view.addSubview(signUpNameTextField)
        view.addSubview(continueButton)
        
        
        _ = signUpNameTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        
        _ = continueButton.anchor(signUpNameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        
    }

    

}

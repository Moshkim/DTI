//
//  SignupController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/30/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Firebase
import FirebaseDatabase
import GoogleSignIn
import UIKit
import KeychainSwift

class SignupController: UIViewController {
    
    
    fileprivate var user: Customer?
    //fileprivate var user: Users?
    
    
    
    let profilePicture: UIImageView = {
        let profile = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        let image = UIImage(named: "profile")?.withRenderingMode(.alwaysTemplate)
        profile.tintColor = UIColor.white
        profile.backgroundColor = UIColor(red:0.10, green:0.38, blue:0.45, alpha:1)
        profile.image = image
        profile.contentMode = .scaleAspectFit
        profile.layer.cornerRadius = profile.frame.width/2
        profile.layer.borderColor = UIColor.white.cgColor
        profile.layer.borderWidth = 1
    

        return profile
    }()
    
    let nameTextField: UITextField = {
        let name = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        name.layer.cornerRadius = 5
        name.textAlignment = .left
        name.backgroundColor = UIColor.clear
        //name.layer.borderColor = UIColor.white.cgColor
        //name.layer.borderWidth = 1
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 40, width: 300, height: 0.6)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        name.layer.addSublayer(bottomLayer)
        
        name.textColor = UIColor.white
        name.typingAttributes?[NSForegroundColorAttributeName] = UIColor.white
        name.attributedPlaceholder = NSAttributedString(string: "  Name", attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    
    let emailTextField: UITextField = {
        let email = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        email.layer.cornerRadius = 5
        email.textAlignment = .left
        email.backgroundColor = UIColor.clear
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 40, width: 300, height: 0.6)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        email.layer.addSublayer(bottomLayer)
        
        
        email.textColor = UIColor.white
        email.typingAttributes?[NSForegroundColorAttributeName] = UIColor.white
        email.attributedPlaceholder = NSAttributedString(string: "  Email", attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    
    let passwordTextField: UITextField = {
        let password = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        password.layer.cornerRadius = 5
        password.textAlignment = .left
        password.backgroundColor = UIColor.clear
        
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 40, width: 300, height: 0.6)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        password.layer.addSublayer(bottomLayer)
        
        
        password.isSecureTextEntry = true
        password.textColor = UIColor.white
        password.attributedPlaceholder = NSAttributedString(string: "  Password", attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        password.translatesAutoresizingMaskIntoConstraints = false
        return password
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor(red:0.10, green:0.38, blue:0.45, alpha:1.00)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(SignupAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    func SignupAction() {
    
    
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            
            let isEmailAddressValid = StringVerification.emailValidation(emailAddressString: email)
            
            if isEmailAddressValid {
                
                print("Email Address is valid")
            } else {
                print("Email Address is not valid")
                let alertViewController = UIAlertController(title: "Invalid Email", message: "Type valid email address!", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "OK", style: .cancel)
                alertViewController.addAction(cancel)
                present(alertViewController, animated: true, completion: nil)
                return
                
            }
            
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil{
                    print("Can not sign un with the email you provided", error?.localizedDescription as Any)
                    
                } else {
                    self.CompleteSignIn(id: (user?.uid)!)
                    self.performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: self.signupButton)
                }
                
                
            })
            
        }
    
    }
    
    fileprivate func CompleteSignIn(id: String){
        let keyChain = DataServiceFirebase().keyChain
        keyChain.set(id, forKey: "uid")
    }
    
    
    
    lazy var backToLoginButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor(red:0.32, green:0.61, blue:0.64, alpha:1.00), for: .normal)
        button.setTitle("Already have an account? Sign In", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(backToLoginAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func backToLoginAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    lazy var dateOfBirth: UIDatePicker = {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.black
        datePicker.tintColor = UIColor.white
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        return datePicker
    }()
    
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        let selectedDate: String = dateFormatter.string(from: sender.date)
    }
     */
    /*
     
     if let email = emailTextfield.text, let password = passwordField.text {
     
     
     let isEmailAddressValid = emailValidation(emailAddressString: email)
     
     if isEmailAddressValid {
     
     print("Email Address is valid")
     } else {
     print("Email Address is not valid")
     let alertViewController = UIAlertController(title: "Invalid Email", message: "Type valid email address!", preferredStyle: .alert)
     let cancel = UIAlertAction(title: "OK", style: .cancel)
     alertViewController.addAction(cancel)
     present(alertViewController, animated: true, completion: nil)
     return
     
     }
     
     
     Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
     if error != nil{
     print("Can not sign un with the email you provided", error?.localizedDescription as Any)
     
     } else {
     self.CompleteSignIn(id: (user?.uid)!)
     self.performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: self.signupButton)
     }
     
     
     })
     
     }
     
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        
        view.addSubview(profilePicture)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signupButton)
        view.addSubview(backToLoginButton)
        
    
    
        _ = profilePicture.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
            profilePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = nameTextField.anchor(nil, left: nil, bottom: view.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 35, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _ = emailTextField.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        _ = passwordTextField.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 35, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = signupButton.anchor(passwordTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = backToLoginButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            backToLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    }
}

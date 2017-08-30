//
//  LoginAndOutViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/28/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Firebase
import FirebaseDatabase
import GoogleSignIn
import UIKit
import KeychainSwift


class LoginAndOutViewController: UIViewController, GIDSignInUIDelegate{
    
    
    
    let mainLogoImage: UIImageView = {
        let image = UIImage(named: "hexagon")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        return imageView
    }()

    
    let emailTextfield: UITextField = {
        let email = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        email.keyboardType = .emailAddress
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
    
    
    let passwordField: UITextField = {
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
    
    lazy var loginButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor(red:0.10, green:0.38, blue:0.45, alpha:1.00)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    func loginAction() {
    
        guard let email = emailTextfield.text else { return }
        guard let password = passwordField.text else { return }
        
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
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error ) in
            if error != nil {
                print("There is a problem with login ", error?.localizedDescription as Any)
            
            } else {
                self.CompleteSignIn(id: (user?.uid)!)
                self.performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: self.loginButton)
            }
        
        
        })
        
        
        //"LoginToRiderStatusSegue"
    }
    
    
    lazy var signupButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor(red:0.32, green:0.61, blue:0.64, alpha:1.00), for: .normal)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(signupAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func signupAction() {
        self.performSegue(withIdentifier: "LoginToSignupSegue", sender: self.signupButton)
    }
    

    
    
    fileprivate func CompleteSignIn(id: String){
        let keyChain = DataServiceFirebase().keyChain
        keyChain.set(id, forKey: "uid")
        
    }
    
    /*
    lazy var googleSignInButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "googleIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        button.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        
        return button
    }()
    
    func googleLogin() {
        //let button = GIDSignInButton()
    
        
    }
    */
    
    fileprivate func setupGoogle() {
        let googleButton = GIDSignInButton()
        googleButton.layer.borderColor = UIColor(red:0.99, green:0.10, blue:0.56, alpha:1.00).cgColor
        googleButton.layer.borderWidth = 0.2
        googleButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        googleButton.style = GIDSignInButtonStyle.iconOnly
        googleButton.colorScheme = GIDSignInButtonColorScheme.dark
        googleButton.layer.cornerRadius = 5
        view.addSubview(googleButton)
        
        _ = googleButton.anchor(signupButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        //UserDefaults.standard.set(signUpNameTextField.text, forKey: "name")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = DataServiceFirebase().keyChain
        
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: nil)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.view.backgroundColor = UIColor.black
        
        
        view.addSubview(mainLogoImage)
        view.addSubview(emailTextfield)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        //view.addSubview(googleSignInButton)
        
        _ = mainLogoImage.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 100, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
            mainLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = emailTextfield.anchor(nil, left: nil, bottom: view.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            emailTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = passwordField.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = loginButton.anchor(passwordField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = signupButton.anchor(loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 50)
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //_ = googleSignInButton.anchor(passwordField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
            //googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        //setupGoogle()
    }

}

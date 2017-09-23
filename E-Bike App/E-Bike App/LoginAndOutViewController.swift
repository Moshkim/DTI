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
import LocalAuthentication


class LoginAndOutViewController: UIViewController, GIDSignInUIDelegate{
    
    
    //let instanceAuthService = AuthService.shared
    
    
    
    
    
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
        email.typingAttributes?[NSAttributedStringKey.foregroundColor.rawValue] = UIColor.white
        email.attributedPlaceholder = NSAttributedString(string: "  Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.7)])
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
        password.attributedPlaceholder = NSAttributedString(string: "  Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.7)])
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
        button.isEnabled = false
        button.setTitleColor(UIColor(white: 1.0, alpha:0.7), for: .normal)
        return button
    }()
    @objc func loginAction() {
        
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
        ProgressHUD.show("Progress...", interaction: false)
        
        
        AuthService.signIn(email: email, password: password, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: self.loginButton)
        }, onError: { error in
            guard let err = error else { return }
            ProgressHUD.showError(err)
        })
        
        
        
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
    
    @objc func signupAction() {
        self.performSegue(withIdentifier: "LoginToSignupSegue", sender: self.signupButton)
    }
    
    
    
    lazy var signInWithTouchIDButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor(red:0.32, green:0.61, blue:0.64, alpha:1.00), for: .normal)
        button.setTitle("Sign In With Touch ID", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(signInWithTouchID), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    @objc func signInWithTouchID() {
        
        authenticationWithTouchID()
        
    }
    
    
    // MARK - Touch ID Authentication
    // FIXIT - The Touch ID does not work properly
    //*****************************************************************************************************************************//
    
    func authenticationWithTouchID() {
        
        let authenticaitonContext = LAContext()
        var error: NSError?
        
        
        if authenticaitonContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            authenticaitonContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Verification"){
                (success, error) in
                if success {
                    print("User has authenticated!")
                    DispatchQueue.main.async {
                        let email = UserDefaults.standard.object(forKey: "email")
                        let password = UserDefaults.standard.object(forKey: "password")
                        
                        AuthService.signIn(email: email as! String, password: password as! String, onSuccess: {
                            self.performSegue(withIdentifier: "LoginToRiderStatusSegue", sender: self.loginButton)
                        }, onError: { error in
                            
                            guard let err = error else { return }
                            ProgressHUD.showError(err)
                        })
                    }
                    
                } else {
                    if let err = error as NSError?{
                        let message = self.errorMessageForLAErrorCode(errorCode: err.code)
                        self.showAlertWithTitle(title: "Error", message: message)
                        
                    }
                }
            }
        }
        
    }
    
    
    func showAlertWithTitle(title: String, message: String) {
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertViewController.addAction(okAction)
        self.present(alertViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    func errorMessageForLAErrorCode(errorCode: Int) -> String {
        switch errorCode {
        case LAError.appCancel.rawValue:
            return "Authentication was cancelled by application"
        case LAError.authenticationFailed.rawValue:
            return "The user failed to provide valid credentials"
        case LAError.invalidContext.rawValue:
            return "The context is invalid"
        case LAError.passcodeNotSet.rawValue:
            return "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            return "Authentication was cancelled by the system"
        case LAError.touchIDLockout.rawValue:
            return "Too many failed attempts"
        case LAError.touchIDNotAvailable.rawValue:
            return "TouchID is not available on the device"
        case LAError.userCancel.rawValue:
            return "The user did cancel"
        default:
            return "Did not find error code on LAError object"
        }
    }
    
    
    
    //*****************************************************************************************************************************//
    
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
        super.viewDidAppear(animated)
        //let keyChain = DataServiceFirebase().keyChain
        
    }
    
    
    func handleTextField() {
        emailTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextfield.text, !email.isEmpty, let password = passwordField.text, !password.isEmpty  else {
            print("Typing the textfields")
            return
        }
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.isEnabled = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.black
        
        
        
        
        view.addSubview(mainLogoImage)
        view.addSubview(emailTextfield)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        view.addSubview(signInWithTouchIDButton)
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
        
        _ = signInWithTouchIDButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 300, heightConstant: 30)
        signInWithTouchIDButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //_ = googleSignInButton.anchor(passwordField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        //googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        handleTextField()
        //setupGoogle()
    }
    
}

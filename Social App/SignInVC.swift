//
//  ViewController.swift
//  Social App
//
//  Created by Timm Liberty on 11/27/16.
//  Copyright © 2016 Briantiumapps. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC : UIViewController {

    @IBOutlet weak var emailField: FancyTextField!
    
    @IBOutlet weak var passwordField: FancyTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cool way to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
            if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            performSegue(withIdentifier: "goToFeed", sender: nil)
            print("In viewDidAppear should have segued. KEY_UID is: \(KEY_UID)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookButtonTapped(_ sender: RoundButton) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Unable to authenticate with Facebook.")
            } else if result?.isCancelled == true {
                print("The user cancelled FB authentication")
            } else {
                print(" Successful authentication")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Successfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                    
                }
                
            }
        })
    }
    @IBAction func signInButtonTapped(_ sender: FancyButton) {
      self.dismissKeyboard()
        if let email = emailField.text, let pwd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Email User Authenticated with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with FireBase using email \(error)")
                            
                            self.handleLoginErrors(errorCode: (error?._code)!)
                            
                        } else {
                            print("Succesfully authenticated with Firebase.")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
        
    }

    func completeSignIn(id: String){
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    func handleLoginErrors(errorCode: Int){
        switch errorCode {
        case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
            print("Wrong Password")
            alertOnLoginError(title: "Log In Error! \(errorCode)", message: "You may have entered the wrong password. You can try again.", actions: ["Try Again"])
        case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
            print("Email in use already.")
            alertOnLoginError(title: "Log In Error! \(errorCode)", message: "This email is already in use, please try your password again.", actions: ["Try Again"])
        case FIRAuthErrorCode.errorCodeWeakPassword.rawValue:
            alertOnLoginError(title: "Log In Error! \(errorCode)", message: "Passwords must be at least 7 characters in length.", actions: ["Try Again"])
            print("Weak password!")
        default:
            alertOnLoginError(title: "Log In Error! \(errorCode)", message: "General log in problem.", actions: ["Send Help Request"])
            print("Error Logging In.")
        }
    }
    
    func alertOnLoginError(title: String, message: String, actions: [String]){
        let logInAlert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for item in actions {
            logInAlert.addAction(UIAlertAction(title: item, style: .default, handler: nil))
        }
        
        logInAlert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        logInAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(logInAlert, animated: true)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

}


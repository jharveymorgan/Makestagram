//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/9/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI

class LoginViewController: UIViewController {
    
    // MARK - Properties
    typealias  FIRUser = FirebaseAuth.User
    //let user: FIRUser? = Auth.auth().currentUser
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // any setup after loading view
    }
    
    // MARK - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // implement AuthViewController within FirebaseUI:
        
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        // assign delegate
        authUI.delegate = self
        
        // present the auth view controller
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }
    
} // end class

// MARK - Extension(s)
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // error handling
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        
        print("handle user sign up / login")
    }
}

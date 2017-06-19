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
import FirebaseDatabase

typealias  FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var loginButton: UIButton!
    //let user: FIRUser? = Auth.auth().currentUser
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // any setup after loading view
    }
    
    // MARK: - IBActions
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

// MARK: - Extension(s)
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // error handling
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        // check that user exists by unwrapping optional
        guard  let user = user
            else { return }
        
        // path to find user's information in database
        //let userRef = Database.database().reference().child("users").child(user.uid)
        
        // read data from previous path
        UserService.show(forUID: user.uid) { (user) in 
            if let user = user {
                // handle existing user
                User.setCurrent(user)
                
                // after existing user logs in, direct to main storyboard
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            } else {
                // new user, set username
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        }
    }
}//end extension

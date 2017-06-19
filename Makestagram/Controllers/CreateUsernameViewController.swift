//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/14/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {
   
    // MARK: - Subviews
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // rounded button edges
        nextButton.layer.cornerRadius = 6
    }

    // MARK: - IBActions
    @IBAction func nextButtonTapped(_ sender: Any) {
        // check to see if there is a current user and if they added a username
        guard  let firUser = Auth.auth().currentUser, let username = usernameTextField.text, !username.isEmpty else {
            return
        }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            print("Create new user \(user.username)")
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            // go to main storyboard
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }
        
//        // go to main storyboard
//        UserService.create(firUser, username: username) { (user) in
//            guard let _ = user else { return }
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: .main)
//            
//            // check main storyboard has an initial view controller
//            if let initalViewController = storyboard.instantiateInitialViewController() {
//                // get reference to current window and set the root view controller to the initial view controller
//                self.view.window?.rootViewController = initalViewController
//                self.view.window?.makeKeyAndVisible()
//            }
//            
//        }
    }
    
}// end class

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
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            // go to main storyboard
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }
    }
    
}// end class

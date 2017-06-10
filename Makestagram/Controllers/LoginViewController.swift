//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/9/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK - Properties
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // any setup after loading view
    }
    
    // MARK - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("login button tapped")
    }
    
}

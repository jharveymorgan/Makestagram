//
//  UserServices.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/16/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        // create dictionary with username
        let userAttrs = ["username": username]
        
        // get path for where data should be stored
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        // write data at specific location
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            // read data we just wrote and create a user from the snapshot
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }//end create
    
}// end struct

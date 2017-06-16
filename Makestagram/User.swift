//
//  User.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/12/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
    // MARK - Properties
    let uid: String
    let username: String
    
    // MARK - Init
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any],
        let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
    }
    
    // MARK: - Singleton
    private static var _current: User?
    
    // get private data
    static var current: User {
        guard let currentUser = _current else { fatalError("Error: Current user doesn't exist") }
        return currentUser
    }
    
    // MARK: - Class Methods
    
    // set private data
    static func setCurrent(_ user: User) {
        _current = user
    }
}

//
//  User.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/12/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    // MARK - Properties
    let uid: String
    let username: String
    var isFollowed = false
    
    // MARK - Init
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any],
            let username = dict[Constants.UserDefaults.username] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        
        super.init()
    }
    
    // allow users to be decoded from data
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        
        super.init()
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
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        
        if writeToUserDefaults {
            // convert user object to Data
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            // store data for the current user in the correck key in UserDefaults
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        
        _current = user
    }
}

// MARK: - Extension(s)
extension User: NSCoding {
    func  encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
}

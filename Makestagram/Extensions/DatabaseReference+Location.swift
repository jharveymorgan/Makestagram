//
//  DatabaseReference+Location.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/22/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension DatabaseReference {
    enum MGLocation {
        // cases to read and write to Firebase Database
        case root
        
        case posts(uid: String)
        case showPost(uid: String, postKey: String)
        
        case showUser(uid: String)
        case showFollowing(uid: String)
        
        case chats(currentUID: String)
        case showChats(currentUID: String)
        
        case messages(chatKey: String)
        case showMessages(chatKey: String)
        
        // convert the case into a DatabaseReference
        func asDatabaseReference() -> DatabaseReference {
            let root = Database.database().reference()
            
            
            switch self {
            case .root:
                return root
            case .posts(let uid):
                return root.child("posts").child(uid)
            case .showPost(let uid, let postKey):
                return root.child("posts").child(uid).child(postKey)
            case .showUser(let uid):
                return root.child("users").child(uid)
            case .showFollowing(let uid):
                return root.child("following").child(uid)
            case .chats(let currentUID):
                return root.child("chats").child(currentUID).childByAutoId()
            case .showChats(let currentUID):
                return root.child("chats").child(currentUID)
            case .messages(let chatKey):
                return root.child("messages").child(chatKey).childByAutoId()
            case .showMessages(let chatKey):
                return root.child("messages").child(chatKey)
            }
        }
    }
    
    static func toLocation(_ location: MGLocation) -> DatabaseReference {
        return location.asDatabaseReference()
    }
    
    
}

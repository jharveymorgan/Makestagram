//
//  LikeService.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/21/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Firebase
import FirebaseDatabase

// like posts, unlike posts, determine whether user has a currently liked post
struct LikeService {
    
    // like a post
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        // each post has a key, check for key
        guard let key = post.key else {
            return success(false)
        }
        // reference to current user
        let currentUID = User.current.uid
        
        // reference to Firebase Database where I want to hold the likes for each post
        // makestagram -> "postLikes" -> specific post's key -> current user's uid, to see who liked the specific post
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
       
        // write data to Firebase Database for liking a post
        likesRef.setValue(true) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            // reference to Firebase Databse where I want to write the like count
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            // completion block to increment like_post after being liked
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check value exists and increment if it does
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                
                // return updated value
                return TransactionResult.success(withValue: mutableData)
            
            // hand completion block if theres and error or not
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
        }
    }
    
    // unlike a post
    static func delete(for post: Post, success: @escaping (Bool) -> Void) {
        // check for post's key
        guard let key = post.key else {
            return success (false)
        }
        
        let currentUID = User.current.uid
        
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
        
        // delete user's like from Firebase Database 
        likesRef.setValue(nil) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            // reference to Firebase Databse where I want to write the like count
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            // completion block to decrement like_post after being unliked
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check value exists and decrement if it does
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                
                // return updated value
                return TransactionResult.success(withValue: mutableData)
            
            // handle completion block if theres an error or not
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
        }
    }
    
    // check if post has already been liked
    static func isPostLiked(_ post: Post, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        // check post has a key
        guard let postKey = post.key else {
            assertionFailure("Error post must have key")
            return completion(false)
        }
        
        //  path to current user's like data for a specific post, if a like were to exist
        let likesRef = Database.database().reference().child("postLikes").child(postKey)
        // check if a value already exists at location I'm reading from, if so, current user has liked the post
        likesRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    // use easily like and unlike posts
    static func setIsLiked(_ isLiked: Bool, for post: Post, success: @escaping (Bool) -> Void) {
        if isLiked {
            create(for: post, success: success)
        } else {
            delete(for: post, success: success)
        }
    }
    
}

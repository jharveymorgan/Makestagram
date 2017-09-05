//
//  ChatService.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 7/21/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatService {
    
    // create new chats in the database
    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        
        // dictionary for each member's uid
        var membersDict = [String: Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        
        // create the chat after the first message is sent
        let lastMessage = "\(message.sender.username): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
        
        // create dictionary of chat JSON object that will be stored in the database
        let chatDict : [String: Any] = ["title": chat.title, "memberHash": chat.memberHash, "members": membersDict, "lastMessage": lastMessage, "lastMessageSent": lastMessageSent]
        
        // generate a new location for the chat object
        let chatRef = DatabaseReference.toLocation(.chats(currentUID: User.current.uid))
        chat.key = chatRef.key
        
        // create dictionary in order to write to multiple locations at once
        var multiUpdateValue = [String: Any]()
        
        // update the member's chats with chat JSON object
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(chatRef.key)"] = chatDict
        }
        
        // generate a new location for the message
        let messageRef = DatabaseReference.toLocation(.messages(chatKey: chatRef.key))
        let messageKey = messageRef.key
        
        // update messages
        multiUpdateValue["messages/\(chatRef.key)/\(messageKey)"] = message.dictValue
        
        // write multiple location update and return a chat object, if it's successful
        let rootRef = DatabaseReference.toLocation(.root)
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            completion(chat)
        }
    }
    
    // check for existing chats between users
    static func checkForExistingChat(with user: User, completion: @escaping (Chat?) -> Void) {
        // get the hash value for each member's uids
        let members = [user, User.current]
        let hashValue = Chat.hash(forMembers: members)
        
        // reference to current user's chat data
        let chatRef = DatabaseReference.toLocation(.showChats(currentUID: User.current.uid))
        
        // create a query for matching the memberHash value in every chat object
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        
        // return the corresponding chat, if it exists
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot, let chat = Chat(snapshot: chatSnap) else { return completion(nil) }
            
            completion(chat)
        })
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        // check the chat's key exists
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        // dictionary to update multiple locations at the same time
        var multiUpdateValue = [String: Any]()
        
        // update the member's chat object
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.username): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        
        // generate a new location for the message
        let messageRef = DatabaseReference.toLocation(.messages(chatKey: chatKey))
        let messageKey = messageRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        // write multiple location update
        let rootRef = DatabaseReference.toLocation(.root)
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
        
    }
}

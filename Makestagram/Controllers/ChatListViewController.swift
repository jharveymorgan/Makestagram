//
//  ChatListViewController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 7/28/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatListViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    var chats = [Chat]()
    
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    
   
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 71
        // remove separators
        tableView.tableFooterView = UIView()
        
        userChatsHandle = UserService.observeChats(withCompletion: { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            // update UI on the main thread
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
    
    // remove observer when view controller is disposed
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    // MARK: - IBActions
    @IBAction func dismissButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }

}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}

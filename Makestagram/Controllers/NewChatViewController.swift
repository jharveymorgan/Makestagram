//
//  NewChatViewController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 9/5/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class NewChatViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var following = [User]()
    var selectedUser: User?
    var existingChat: Chat?
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
        // get rid of separators for empty cells
        tableView.tableFooterView = UIView()
        
        // get all the people a user is following
        UserService.following { [weak self] (following) in
            self?.following = following
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        // check that a user has been selected
        guard let selectedUser = selectedUser else { return }
        
        // disable the next button, so the user doesn't tap it multiple times
        sender.isEnabled = false
        // check for an existing chat between the users
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            // set the existingChat, if it exists
            sender.isEnabled = true
            self.existingChat = chat
            
            // go to the ChatViewController
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatUserCell") as! NewChatUserCell
        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: NewChatUserCell, at indexPath: IndexPath) {
        let follower = following[indexPath.row]
        cell.textLabel?.text = follower.username
        
        // change accessory to a checkmark if the user has selected a user
        if let selectedUser = selectedUser, selectedUser.uid == follower.uid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

// MARK: - UITableViewDelegate
extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // reference to the tableViewCell at the selected indexPath
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // keep track of the selected users and update the UI
        selectedUser = following[indexPath.row]
        cell.accessoryType = .checkmark
        
        // only enable if at least one user is checked
        nextButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // reference to the tableViewCell at the selected indexPath
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // get rid of the checkmark, since the user has de-selected that user
        cell.accessoryType = .none
    }
}

// MARK: - Navigation
extension NewChatViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat", let destination = segue.destination as? ChatViewController, let selectedUser = selectedUser {
            // either find an existing chat or create a new chat with these members
            let members = [selectedUser, User.current]
            destination.chat = existingChat ?? Chat(members: members)
            
        }
    }
}


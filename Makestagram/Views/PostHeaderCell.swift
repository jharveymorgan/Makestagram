//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 54
    
    // MARK: - Properties
    @IBOutlet weak var usernameLabel: UILabel!

    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    @IBAction func optionsButtonTapped(_ sender: Any) {
        
    }
}

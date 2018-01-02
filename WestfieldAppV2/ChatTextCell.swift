//
//  ChatTextCell.swift
//  WatsonDemo
//
//  Created by RAHUL on 4/11/17.
//  Copyright © 2017 RAHUL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ChatTextCell: UITableViewCell {

    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

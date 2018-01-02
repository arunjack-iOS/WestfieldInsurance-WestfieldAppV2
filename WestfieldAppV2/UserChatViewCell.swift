//
//  UserChatViewCell.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/13/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import UIKit

class UserChatViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var buttonsView: ButtonsView!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var rightTriangleView: UIImageView!
    @IBOutlet weak var userIcon: UIImageView!
    var callValue : Bool = true
    


    // MARK: - Constraints
    @IBOutlet weak var buttonsLeadingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var chatViewController: AdviceViewController?
    var initialButtonsLeadingConstraint: CGFloat!
    var message: Message?

    /// Configure user chat table view cell with user message
    ///
    /// - Parameter message: Message instance
    func configure(withMessage message: Message) {
        self.message = message

        if var text = message.text,
            text.characters.count > 0 {
            messageLabel.text = text
        }

        messageLabel.textColor = UIColor.iwiChatText
        buttonsView.configure(withOptions: nil,
                              viewWidth: buttonsView.frame.width,
                              userChatViewCell: self)

        initialButtonsLeadingConstraint = initialButtonsLeadingConstraint ?? buttonsLeadingConstraint.constant
        buttonsLeadingConstraint.constant = initialButtonsLeadingConstraint + (buttonsView.viewWidth - buttonsView.maxX)/2

    }

    // MARK: - Actions
    func optionButtonTapped(withSelectedButton selectedButton: String) {

        message?.options = nil
        message?.text = selectedButton
    
        /// Update message
        if let indexPath = chatViewController?.chatTableView.indexPath(for: self),
           let message = message {
            chatViewController?.messages[indexPath.row] = message
            chatViewController?.dismissKeyboard()
        }

        userIcon.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, animations: { [weak self] in
            self?.layoutIfNeeded()
        }, completion: { result in
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateChatField(notification: NSNotification) {
        
        let value = notification.value(forKey: "object") as! String!
        
        self.optionButtonTapped(withSelectedButton: value!)
    }

    // MARK: - Private
    /// Once the user has tapped an option button, the cell needs to be resized and so we reload it to shrink it
    private func reloadCell() {
        // This is needed to resize the ButtonsView correctly
        if let indexPath = self.chatViewController?.chatTableView.indexPath(for: self) {
            self.chatViewController?.chatTableView.reloadRows(at: [indexPath], with: .none)
            self.chatViewController?.scrollChatTableToBottom()
        }
    }


}

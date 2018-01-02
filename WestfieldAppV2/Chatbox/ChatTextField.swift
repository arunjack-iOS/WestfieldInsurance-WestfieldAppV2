//
//  ChatTextField.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/14/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import UIKit

class ChatTextField: UITextField {

    // MARK: - Properties
    let chatInputAccessoryView = ChatInputAccessoryView()
    var chatViewController: AdviceViewController!
    var debugChatIndex = 1

    // MARK: - View Lifecycle
    override func awakeFromNib() {
        delegate = self
    }

}

// MARK: - UITextFieldDelegate
extension ChatTextField: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool  {
        guard inputAccessoryView == nil else {
            inputAccessoryView = nil
            chatViewController.chatTableBottomConstraint.constant = 15

            /// Animate chatTable DOWN with dismissal of keyboard and scroll to last row
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.chatViewController.view.layoutIfNeeded()
                strongSelf.chatViewController.scrollChatTableToBottom()
            }

            return false
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //setupSimulator()

        /// Setup the chat text field with an input accessory view of InputAccessoryView
        chatInputAccessoryView.chatViewController = chatViewController
        inputAccessoryView = chatInputAccessoryView.contentView

        /// Animate chatTable UP with showing of keyboard
        chatViewController.chatTableBottomConstraint.constant = 250

        // I'm not sure why this delay is needed but without it the keyboard won't dismiss
        let when = DispatchTime.now() + 0.01
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.chatViewController.view.layoutIfNeeded()
                self?.chatInputAccessoryView.inputTextField.becomeFirstResponder()
                self?.chatViewController.scrollChatTableToBottom()
            }
        }
    }

    
}

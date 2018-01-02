//
//  ChatInputAccessoryView.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/14/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import UIKit

class ChatInputAccessoryView: NSObject {

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    var messsage = ""
    

    // MARK: - Properties
    var chatViewController: AdviceViewController!

    // MARK: - View Lifecycle
    override init() {
        super.init()
        setupNib()
    }

    // MARK: - Actions
    @IBAction func sendButtonTapped() {
        sendMessage()
    }
    
    func updateChatField(notification: NSNotification) {
        NSLog("Object is %@", notification.value(forKey: "object") as! String!)
        
        inputTextField.text = notification.value(forKey: "object") as! String!
        
    }

    // MARK: - Private
    private func setupNib() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        
        inputTextField.setLeftPaddingPoints(10)
    }

    /// Send message, append it to chat view - and only then dismiss keyboard
    private func sendMessage() {
        let userMessage = Message(type: MessageType.User, text: inputTextField.text!, options: nil,enableButton: true,selectedOption:"")
        self.chatViewController.appendChat(withMessage: userMessage)
        inputTextField.text = ""

        /// Delay dismissal of keyboard after sending message to allow for animation of new table row to complete
        let when = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: when + 0.3) {
            self.inputTextField.resignFirstResponder()
            self.chatViewController.chatTableBottomConstraint.constant = 10
        }
    }

}

// MARK: - UITextFieldDelegate
extension ChatInputAccessoryView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //let whitespaceSet = NSCharacterSet.whitespaces
        
        if (range.location == 0 && (string == " ")){
            return false
        }else{
            return true
        }
        
        
    }
    
}

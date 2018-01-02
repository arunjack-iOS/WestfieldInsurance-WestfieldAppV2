//
//  Message.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/14/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation

// MARK: - Type
enum MessageType {
    case Map
    case User
    case Watson
    case Video
    case image
}

public struct Message {

    // MARK: - Properties
    var options: [String]?
    var text: String?
    var type: MessageType
    var mapUrl: URL?
    var videoUrl: URL?
    var imageUrl: URL?
    var isEnableRdBtn : Bool
    var selectedOption: String?
    

    init(type: MessageType, text: String?, options: [String]?, enableButton:Bool,selectedOption: String? ) {
        self.type = type
        self.text = text
        self.options = options
        self.isEnableRdBtn = enableButton
        self.selectedOption = selectedOption
    }

}

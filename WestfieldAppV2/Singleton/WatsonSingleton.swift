//
//  WatsonSingleton.swift
//  WatsonDemo
//
//  Created by RAHUL on 4/6/17.
//  Copyright © 2017 RAHUL. All rights reserved.
//

import Foundation
import BoxContentSDK

class watsonSingleton {
    
    static let sharedInstance : watsonSingleton = {
        let instance = watsonSingleton()
        return instance
    }()
    
    var isVoiceOn : Bool = false
    var isToolBoxDetailClicked : Bool = false
    var itemValue = [BOXItem]()
    
}

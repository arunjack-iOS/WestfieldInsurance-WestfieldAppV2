//
//  AttributedLable.swift
//  WatsonDemo
//
//  Created by RAHUL on 3/21/17.
//  Copyright © 2017 RAHUL. All rights reserved.
//

import Foundation

extension String {

    func trim(to maximumCharacters: Int) -> String {
        return substring(to: index(startIndex, offsetBy: maximumCharacters)) + "..."
    }
}

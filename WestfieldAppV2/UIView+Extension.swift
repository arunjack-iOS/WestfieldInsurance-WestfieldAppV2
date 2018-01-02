//
//  UIView+Extension.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/29/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
    }

}

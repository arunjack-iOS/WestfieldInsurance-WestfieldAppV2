//
//  GradientView.swift
//  WatsonDemo
//
//  Created by RAHUL on 12/4/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable final class GradientView: UIView {

    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear

    override func draw(_ rect: CGRect) {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: superview!.frame.size.width,
                                height: superview!.frame.size.height - 120)
        gradient.colors = [startColor.cgColor, endColor.cgColor]

        layer.addSublayer(gradient)
    }

}

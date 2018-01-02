//
//  WatsonChatViewCell.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/13/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import TTTAttributedLabel
import UIKit
import AVFoundation


protocol watsonChatCellDelegate
{
    func loadUrlLink(url : String?)
    func SendMessageWithButtonValue(with value:String, atIndex : Int)
    
}

class WatsonChatViewCell: UITableViewCell {
   // let buttonOptions = KGRadioButton()
    var delegate: watsonChatCellDelegate!
    @IBOutlet weak var chatBubbleTableView: UITableView!
    @IBOutlet weak var chatStackView: UIStackView!
    var indexNumber : Int!
    
    

    // MARK: - Doc
    private struct Doc {
        
        static var linkUrl = [String]()
        static let employerPolicy = "https://drive.google.com/file/d/0B-UVZVvBHs8uUjJiSXJlS2NXRGxOd3YtX1cxbExhYXhfUXlz/view?usp=sharing"
        static let driverTraining = "https://drive.google.com/file/d/0B-UVZVvBHs8uQ1puaXhBYS11SFdfUHZEWXZqSFN2T29xSmMw/view?usp=sharing"
        static let vehicleInspection = "https://drive.google.com/file/d/0B-UVZVvBHs8ueVVDOHkza2hKNVNyanNZSXFUTkFpZldnSEdR/view?usp=sharing"
        static let fleetProgram = "https://drive.google.com/file/d/0B-UVZVvBHs8uRjUySlZLYS1mYTdqU3FzbkNvVzlJaTBfajBV/view?usp=sharing"
    }

    // MARK: - Outlets

    @IBOutlet weak var chatBgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBGvw: CustomView!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    @IBOutlet weak var watsonIcon: UIImageView!
    @IBOutlet weak var heightLable: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var optionData = [String]()
    var linkUrlArr = [String]()
    var regexArr = [NSRange]()
    var isbuttonEnable : Bool = true
    var selectedButtonTitle : String? = ""
    
    var chatViewController: AdviceViewController?
    /// Configure Watson chat table view cell with Watson message
    ///
    /// - Parameter message: Message instance
    func configure(withMessage message: Message) {
        self.addItemsInStckView()
        
        var text = message.text!
        messageLabel.delegate = self
        messageLabel.textInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.isbuttonEnable = message.isEnableRdBtn
        self.selectedButtonTitle = message.selectedOption
        for aView in chatStackView.arrangedSubviews{
            if aView .isKind(of: UIStackView.self) {
                chatStackView.removeArrangedSubview(aView)
                aView.removeFromSuperview()
            }
        }
        
        if text.contains("</sub>"){
            
            var foundText = ""
            
            let range2 = text.range(of: "(?<=<sub alias=)[^><]+(?=>)", options: .regularExpression)
            if range2 != nil {
                var correctedArray = [String]()
                let nsString = text as NSString
                let regex = try! NSRegularExpression(pattern: "(?<=<sub alias=)[^><]+(?=>)")
                for text in regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)) {
                    print(text.numberOfRanges)
                    for i in 0..<text.numberOfRanges{
                        let  rangg = text.range(at: i)
                        
                        var stringST = nsString.substring(with: rangg)
                        stringST = stringST.replacingOccurrences(of: "\"", with: "")
                        stringST = stringST.replacingOccurrences(of: "\\", with: "")
                       // print(stringST)
                        correctedArray.append(stringST)
                        
                    }
                }
                foundText = text
                
                if correctedArray.count>0{
                    
                    for i in 0..<correctedArray.count{
                        let rangeText2 = foundText.range(of:"<sub[^>]*>(.*?)</sub>", options:.regularExpression)
                        print(i)
                        if rangeText2 != nil {
                            let optionsStringNew = foundText.substring(with: rangeText2!)
                            print(optionsStringNew)
                            let replaceStr = optionsStringNew.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                            foundText = foundText.replacingOccurrences(of: optionsStringNew, with: replaceStr)
                            //print(foundText)
                            //print(text)
                            text = foundText
                            
                        }
                    }
                }
                
            }
            
        }
        var range1: NSRange? = nil
        self.linkUrlArr.removeAll()
        self.regexArr.removeAll()
        
        text = text.replacingOccurrences(of: "<br>", with: "\n")
        optionData.removeAll()
        text = text.replacingOccurrences(of: "\",\"", with: "\n\n")
        
        
        let nsString = text as NSString
        let regex = try! NSRegularExpression(pattern: "([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])")
        for textN in regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)) {
            print(textN.numberOfRanges)
            for i in 0..<textN.numberOfRanges{
                let  rangg = textN.range(at: i)
                
                var stringST = nsString.substring(with: rangg)
                stringST = stringST.replacingOccurrences(of: "\"", with: "")
                stringST = stringST.replacingOccurrences(of: "\\", with: "")
                if self.linkUrlArr.contains(stringST) == false {
                    self.linkUrlArr.append(stringST)
                }
                text = text.replacingOccurrences(of: stringST, with: "")
                let range = text.range(of:"<a[^>]*>(.*?)</a>", options:.regularExpression)
                if range != nil {
                    let found = text.substring(with: range!)
                    let foundStr = found.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    text = text.replacingOccurrences(of: found, with: foundStr)
                    let nsText = text as NSString
                    range1 = nsText.range(of: foundStr)
                    self.regexArr.append(range1!)
                }
                
            }
        }
        

        var foundNew = text
        
        let rangeNew = foundNew.range(of:"(?=<)[^.]+(?=>)", options:.regularExpression)
        let rangeNew2 = foundNew.range(of:"(?=<)[^.]+(?=<\\)", options:.regularExpression)
        if (rangeNew != nil || rangeNew2 != nil) {
            let subString = foundNew.substring(with: rangeNew!)
            foundNew = foundNew.replacingOccurrences(of: subString, with: "")
            if subString.contains("<wcs:input>") {
                var foundRedioBtnData = subString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                foundRedioBtnData = foundRedioBtnData.replacingOccurrences(of: "</wcs:input", with: "")
                foundRedioBtnData = foundRedioBtnData.replacingOccurrences(of: "\n\n", with: "n&n")
                optionData = foundRedioBtnData.components(separatedBy: "n&n")
            }
            
            let when = DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: when + 0.5) {
                

            }
            
            if self.optionData.count>0 {
                self.addRadioButtonsWithTitle(count: self.optionData.count)
            }

        }
        foundNew = foundNew.replacingOccurrences(of: ">,", with: "")
        foundNew = foundNew.replacingOccurrences(of: ">", with: "")
        foundNew = foundNew.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        messageLabel.text = foundNew
        
        
        if self.linkUrlArr.count > 0 && self.regexArr.count>0 {
            for i in 0..<self.linkUrlArr.count{
                messageLabel.addLink(to: URL(string: self.linkUrlArr[i]), with: self.regexArr[i])
            }
            
        }
        
//        if range1 != nil{
//            messageLabel.addLink(to: URL(string: Doc.linkUrl) , with: range1!)
//        }
        
        //self.chatStackView.layoutIfNeeded() // Updates the frames

    
    }


    func addItemsInStckView() {
        
        chatStackView.axis  = UILayoutConstraintAxis.vertical
        chatStackView.alignment = UIStackViewAlignment.leading
        chatStackView.spacing   = 5.0
        chatStackView.translatesAutoresizingMaskIntoConstraints = false;
    }

    
    /*let button = makeButtonWithText(tag: i)
     let lable = makeTextLableWithText(index: i)
     
     let btnTitle = optionData[i]
     if btnTitle == self.selectedButtonTitle!{
     button.isSelected = true
     }*/
    
    
    func addRadioButtonsWithTitle(count:Int){
        
        messageLabel.textInsets = UIEdgeInsetsMake(17, 12, 5, 12)
       // chatStackView.setNeedsLayout()
        //chatStackView.layoutIfNeeded()
        
//        self.chatStackView.layoutIfNeeded() // Updates the frames
//        print(chatStackView.frame.size.width)
        
        
         for i in 0..<count{
           
            let optionsView = self.checkboxWithTitle(i)

            var viewArray = [UIView]()
            viewArray += [optionsView]
            let stackView = UIStackView(arrangedSubviews: viewArray)
            chatStackView.spacing   = 0.0
            chatStackView.addArrangedSubview(stackView)
         }
        
        

    }
    
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        if self.optionData.count>0 {
            print("Bounds>>>>>>>>>>>>>>>>>>>>>> \(chatStackView.bounds.size.width)")
            print("fame>>>>>>>>>>>>>>>>>>>>>> \(chatStackView.frame.size.width)")
            print("Message Width>>>>>>>>>>>>>>>>>>>>>> \(messageLabel.frame.size.width)")
            print("BG Width>>>>>>>>>>>>>>>>>>>>>> \(chatBGvw.frame.size.width)")
            print("BG founds>>>>>>>>>>>>>>>>>>>>>> \(chatBGvw.bounds.size.width)")

        }

    }
    
    func checkboxWithTitle(_ index: Int) -> UIView {
        
       // chatStackView.layoutIfNeeded()

        let optionView = UIView()

//        let leftMargin = NSLayoutConstraint(item: optionView, attribute: .leading, relatedBy: .equal, toItem: chatStackView, attribute: .leading, multiplier: 1.0, constant: 0)
//        let rightMargin = NSLayoutConstraint(item: chatStackView, attribute: .trailing, relatedBy: .equal, toItem: optionView, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        var resizedWidth: CGFloat = 0.0
        
        let actualWidth: CGFloat = (UIScreen.main.bounds.size.width * 0.742) + 2
        
        if chatStackView.frame.size.width < actualWidth {
            resizedWidth = actualWidth
        } else {
            resizedWidth = chatStackView.frame.size.width
        }
        
        print(">>>>>>>\(UIScreen.main.bounds.size.width)<<<<<<<")

        print(">>>>>>>\(resizedWidth)<<<<<<<")
        chatStackView.clipsToBounds = true
        
        optionView.tag = tag
        optionView.widthAnchor.constraint(equalToConstant: resizedWidth).isActive = true
        optionView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
       
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: resizedWidth, height: 1))
        lineView.backgroundColor = UIColor.iwiSilver
        optionView.addSubview(lineView)

        let checkBoxImgV = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        checkBoxImgV.backgroundColor = UIColor.clear
        checkBoxImgV.image = UIImage(named: "Uncheck")
        
        
        let titleLabel = TTTAttributedLabel(frame: CGRect(x: resizedWidth/3.5, y: 14.5, width: resizedWidth/1.8, height: 16))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont(name: "Arial-BoldMT", size: 14.0)
        titleLabel.textColor = UIColor.iwiMainBlue
        titleLabel.addSubview(checkBoxImgV)
        titleLabel.textInsets = UIEdgeInsetsMake(0, 22, 0, 5)

        let myButton = UIButton()
        myButton.frame = CGRect(x: 0, y: 0, width: resizedWidth, height: 45)
       myButton.tag = index
       myButton.addTarget(self,action:#selector(manualAction(sender:)) ,for: .touchUpInside)
    
        if isbuttonEnable == false {
            myButton.isEnabled = false
        }
        
        
        let btnTitle = optionData[index]
        if btnTitle == self.selectedButtonTitle!{
            myButton.isSelected = true
            titleLabel.textColor = UIColor.iwiButtonSelected
            checkBoxImgV.image = UIImage(named: "Check")

        } else {

        }

        titleLabel.text = optionData[index]
        optionView.addSubview(titleLabel)

        optionView.addSubview(myButton)

        
        return optionView
    }
    
    
    func makeButtonWithText(tag:Int) -> KGRadioButton {
        //Initialize a button
        print("ENABLE....\(isbuttonEnable)")
        let myButton = KGRadioButton()
        myButton.tag = tag
        myButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        myButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        //myButton.widthAnchor.constraint(equalToConstant: 25)
        myButton.outerCircleColor = UIColor.iwiMainBlue
        myButton.addTarget(self,action:#selector(manualAction(sender:)) ,for: .touchUpInside)
        if isbuttonEnable == false {
            myButton.isEnabled = false
            myButton.alpha = 0.5
        }
        
        return myButton
    }
    
    func makeTextLableWithText(index:Int) -> UILabel {
        print(index)
        let textTitleLabel = UILabel()
        textTitleLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        textTitleLabel.font = UIFont.systemFont(ofSize: 14)
        textTitleLabel.text = optionData[index]
        return textTitleLabel
    }
        
    @objc func manualAction (sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            self.delegate?.SendMessageWithButtonValue(with: optionData[sender.tag],atIndex: indexNumber)
            
        } else{
        }
    }

        //setupHyperLinks()
    //}

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    

    
    
func alert(_ title: String, message: String) {

}
}


 //MARK: - ConversationServiceDelegate
extension WatsonChatViewCell: TTTAttributedLabelDelegate {

    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
       // UIApplication.shared.openURL(url)
        let urlString: String = url.absoluteString
        self.delegate.loadUrlLink(url:urlString)
    }
    
}

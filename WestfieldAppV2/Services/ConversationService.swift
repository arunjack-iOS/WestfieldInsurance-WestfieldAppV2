//
//  ConversationService.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/15/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation

protocol ConversationServiceDelegate: class {
    func didReceiveMessage(withText text: String, options: [String]?)
    func didReceiveMap(withUrl mapUrl: URL)
    func didReceiveImage(withUrl imageUrl: URL, andScale:String)
    func didReceiveImageResizeFactor(with Value:Float)
    func didReceiveVideo(withUrl videoUrl: URL)
    func errorReceiveResponse()
    
    func didReceiveMessageForTexttoSpeech(withText text: String)
    
}


class ConversationService {

    // MARK: - Properties
    weak var delegate: ConversationServiceDelegate?
    var context = ""
    var firstName: String?
    var value1: String?
    var value2: String?
    var value3: String?

    // MARK: - Constants
    private struct Constants {
        static let lastName = "Smith"
        static let httpMethodGet = "GET"
        static let httpMethodPost = "POST"
        static let nName = "Jane"
        static let statusCodeOK = 200
    }

    // MARK: - Key
    private struct Key {
        static let context = "context"
        static let cValue1 = "cvalue1"
        static let cValue2 = "cvalue2"
        static let cValue3 = "cvalue3"
        static let input = "input"
        static let firstName = "fname"
        static let lastName = "lname"
        static let nName = "nname"
        static let workspaceID = "workspace_id"
        static let idV = "id"
    }

    // MARK: - Map
    private struct Map {
        static let mapOne = "https://maps.googleapis.com/maps/api/staticmap?format=png&zoom=17&size=590x300&markers=icon:http://chart.apis.google.com/chart?chst=d_map_pin_icon%26chld=cafe%257C996600%7C10900+South+Parker+road+Parker+Colorado&key=AIzaSyA22GwDjEAwd58byf7JRxcQ5X0IK6JlT9k"
        static let mapTwo = "https://maps.googleapis.com/maps/api/staticmap?maptype=satellite&format=png&zoom=18&size=590x300&markers=icon:http://chart.apis.google.com/chart?chst=d_map_pin_icon%26chld=cafe%257C996600%7C10900+South+Parker+road+Parker+Colorado&key=AIzaSyA22GwDjEAwd58byf7JRxcQ5X0IK6JlT9k"
        static let mapThree = "https://maps.googleapis.com/maps/api/staticmap?format=png&zoom=13&size=590x300&markers=icon:http://chart.apis.google.com/chart?chst=d_map_pin_icon%26chld=cafe%257C996600%7C1000+Jasper+Avenue+Edmonton+Canada&key=AIzaSyA22GwDjEAwd58byf7JRxcQ5X0IK6JlT9k"
        static let mapFour = "https://maps.googleapis.com/maps/api/staticmap?maptype=satellite&format=png&zoom=18&size=590x300&markers=icon:http://chart.apis.google.com/chart?chst=d_map_pin_icon%26chld=cafe%257C996600%7C1000+Jasper+Avenue+Edmonton+Canada&key=AIzaSyA22GwDjEAwd58byf7JRxcQ5X0IK6JlT9k"
    }

    private struct Video {
        static let videoOne = Bundle.main.path(forResource: "Movie1", ofType:"mp4")!
        static let videoTwo = Bundle.main.path(forResource: "Movie2", ofType:"mp4")!
    }

    // MARK: - Init
    init(delegate: ConversationServiceDelegate) {
        self.delegate = delegate
    }

    func sendMessage(withText text: String) {
        print("Send Msg called")
        if firstName == nil && text == "-1" {
            firstName = text
            
            context = ""
        }
        
        let trimmedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        print(trimmedString)
        let userDataId = UserDefaults.standard.value(forKey: "UserDetail") as! NSArray
        let dict2 = userDataId[0] as? Dictionary<String,AnyObject>
        let idValue = (dict2?["_id"] as? String!)!
        
        let requestParameters =
            [Key.input: trimmedString,
             Key.idV: idValue,
             Key.context: context
        ]

        print(requestParameters)
        var request = URLRequest(url: URL(string: GlobalConstants.wcsWorkflowURL)!)
        
        request.httpMethod = Constants.httpMethodPost
        request.httpBody = requestParameters.stringFromHttpParameters().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { [weak self] in

                guard let data = data, error == nil else {
                    return
                }

                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != Constants.statusCodeOK {
                   // print("Failed with status code: \(httpStatus.statusCode)")
                }

                let responseString = String(data: data, encoding: .utf8)
                if let data = responseString?.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            print("JSON Value...\(json)")
                            self?.parseJson(json: json)
                        }
                    } catch {
                        // No-op
                    }

                }
            }
        }

        /// Delay conversation request so as to give the keyboard time to dismiss and chat table view to scroll bottom
        let when = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: when + 0.3) {
            task.resume()
        }

    }

    func parseJson(json: [String:AnyObject]) {
        if (json["context"] as? String) != nil{
            self.context = (json["context"] as? String)!
        }
        else{
            delegate?.errorReceiveResponse()
        }
        var text = ""
        if (json["text"] as? String) != nil {
             text = json["text"] as! String
        }else{
            delegate?.errorReceiveResponse()
        }
        var opt = [String]()
        
        self.delegate?.didReceiveMessageForTexttoSpeech(withText: text)
        
        var scaleValue = ""
        
        let range2 = text.range(of: "(?<=<img:src resize=)[^><]+(?=>)", options: .regularExpression)
        if range2 != nil {
            var optionsString = text.substring(with: range2!)
            optionsString = optionsString.replacingOccurrences(of: "\"", with: "")
            scaleValue = optionsString
            let rangeReplace = text.range(of: "<img:src[^>]*>", options: .regularExpression)
            if rangeReplace != nil {
                var optionsStringIm = text.substring(with: rangeReplace!)
                optionsStringIm = optionsStringIm.replacingOccurrences(of: "\"", with: "")
                text = text.replacingOccurrences(of: optionsStringIm, with: "<img:src>")
            }
            
        }
        var textN = text.replacingOccurrences(of: "", with: " ")
        let rangeImage = text.range(of:"<img:src>(.*?)</img:src>", options:.regularExpression)
        let rangeVideo = text.range(of:"<vid:src>(.*?)</vid:src>", options:.regularExpression)
        
        if (rangeImage != nil) {
        
            var optionsString = text.substring(with: rangeImage!)
            textN = textN.replacingOccurrences(of: optionsString, with: "MIVD.n&n")
            textN = textN.replacingOccurrences(of: "\",\"", with: "n&n")
            optionsString = optionsString.replacingOccurrences(of: "<img:src>", with: "")
            optionsString = optionsString.replacingOccurrences(of: "</img:src>", with: "")
            optionsString = optionsString.replacingOccurrences(of: "</vid:src", with: "")
            optionsString = optionsString.replacingOccurrences(of: "<vid:src>", with: "")
            
            opt = textN.components(separatedBy: "n&n")
            if opt.count > 0{
                for item in 0..<opt.count{
                    /// sleep(1)
                    var chatTxt = opt[item]
                    //print(chatTxt)
                    chatTxt = chatTxt.replacingOccurrences(of: "</vid:src>", with: "")
                    chatTxt = chatTxt.replacingOccurrences(of: "</img:src>", with: "")
                    if chatTxt.contains("MIVD.") {
                        chatTxt = chatTxt.replacingOccurrences(of: "MIVD.", with: "")
                        chatTxt = chatTxt.replacingOccurrences(of: "<img:src>", with: "")
                        if chatTxt.characters.count>0 {
                            self.delegate?.didReceiveMessage(withText: chatTxt, options: nil)
                        }
                        
                        let imageUrl = URL(string: optionsString)
                        if scaleValue != "" {
                            self.delegate?.didReceiveImage(withUrl: imageUrl!, andScale: scaleValue)
                        }else{
                            self.delegate?.didReceiveImage(withUrl: imageUrl!, andScale: "1.0")
                        }
                        
                    }else{
                        self.delegate?.didReceiveMessage(withText: chatTxt, options: nil)
                    }
                    
                }
            }
            else{
                self.delegate?.didReceiveMessage(withText: text, options: nil)
            }
        }
        else if (rangeVideo != nil){
            
            var optionsString = text.substring(with: rangeVideo!)
            textN = textN.replacingOccurrences(of: optionsString, with: "MIVD.n&n")
            textN = textN.replacingOccurrences(of: "\",\"", with: "n&n")
            
            optionsString = optionsString.replacingOccurrences(of: "<img:src>", with: "")
            optionsString = optionsString.replacingOccurrences(of: "</img:src>", with: "")
            optionsString = optionsString.replacingOccurrences(of: "</vid:src>", with: "")
            optionsString = optionsString.replacingOccurrences(of: "<vid:src>", with: "")
            opt = textN.components(separatedBy: "n&n")
            if opt.count > 0{
                for item in 0..<opt.count{
                    /// sleep(1)
                    var chatTxt = opt[item]
                    //print(chatTxt)
                    chatTxt = chatTxt.replacingOccurrences(of: "</vid:src>", with: "")
                    chatTxt = chatTxt.replacingOccurrences(of: "</img:src>", with: "")
                    if chatTxt.contains("MIVD.") {
                        chatTxt = chatTxt.replacingOccurrences(of: "MIVD.", with: "")
                        
                        chatTxt = chatTxt.replacingOccurrences(of: "<vid:src>", with: "")
                        if chatTxt.characters.count>0 {
                            self.delegate?.didReceiveMessage(withText: chatTxt, options: nil)
                        }
                        let videoUrl = URL(string: optionsString)
                        self.delegate?.didReceiveVideo(withUrl: videoUrl!)
                        
                    }else{
                        self.delegate?.didReceiveMessage(withText: chatTxt, options: nil)
                    }
                    
                }
            
        }
        }
        else{
           self.delegate?.didReceiveMessage(withText: text, options: nil)
        }
        
    }

    func getValues() {
        
        self.sendMessage(withText: "-1")
    }

    func findMatch(pattern: String, text: String) -> String {
        // Look for the option params in the brackets
        let nsString = text as NSString
        let regex = try! NSRegularExpression(pattern: pattern)
        if let result = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)).first {
            let matchString = nsString.substring(with: result.range)
            return matchString
        }

        return ""
    }
}





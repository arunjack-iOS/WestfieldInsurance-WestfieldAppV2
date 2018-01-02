//
//  MiscellaneousService.swift
//  WatsonDemo
//
//  Created by RAHUL on 3/22/17.
//  Copyright © 2017 RAHUL. All rights reserved.
//

import Foundation
import JWT



@objc protocol MiscellaneousServiceDelegate: class {
    func didReceiveMessage(withText text: Any)
    @objc optional func didReceiveProfile(withText text: NSMutableArray)
    //optional func didReceiveProfile(withText text: NSMutableArray)
}


enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}



class MiscellaneousService {
    
    weak var delegate: MiscellaneousServiceDelegate?
    //var value = [Dictionary]
    
    var value: [String] = []
    var firstName: String?
    
    
    private struct ServiceTypeConstants {
        static let lastName = "Smith"
        static let httpMethodGet = "GET"
        static let httpMethodPost = "POST"
        static let httpMethodPut = "PUT"
        static let nName = "Jane"
        static let statusCodeOK = 200
    }
    
    // MARK: - Key
    private struct BodyKey {
        static let username = "username"
        static let password = "password"
        static let preferredfirstname  = "preferredfirstname"
        static let preferredlastname  = "preferredlastname"
        static let cellphonenumber = "cellphonenumber"
        static let email = "email"
        static let id = "id"
        static let voice = "voice"
        static let alg = "alg"
        static let type = "typ"
        static let kid = "kid"
        static let iss = "iss"
        static let sub = "sub"
        static let box_sub_type = "box_sub_type"
        static let aud = "aud"
        static let jti = "jti"
        static let exp = "exp"
        static let grant_type = "grant_type"
        static let clientId = "client_id"
        static let clientSecret = "client_secret"
        static let assertionValue = "assertion"
//        -d 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&assertion=YOUR_JWT_ASSERTION' \
//        -X POST
        
            
        
    }
    
    
    init(delegate: MiscellaneousServiceDelegate) {
        self.delegate = delegate
    }
    
    
    
    
    
    
    func serviceCallforUserUpdate(withText firstName: String,and lastName:String, and phone:String, and email:String, and Id: String, and voice : String) {
        print("Send Msg called")
        
        print("Send Msg called with text..\(firstName,lastName,Id)")
        
        var finalContent : String!
        
        let requestParametersNew =
            [BodyKey.preferredfirstname: firstName,
             BodyKey.preferredlastname: lastName,
             BodyKey.cellphonenumber : phone,
             BodyKey.email : email,
             BodyKey.id : Id,
             BodyKey.voice : voice
        ]
        
        if let json = try? JSONSerialization.data(withJSONObject: requestParametersNew, options: []) {
            if let content = String(data: json, encoding: String.Encoding.utf8) {
                print(content)
                finalContent = content
                
                var request2 = URLRequest(url: URL(string: GlobalConstants.userDetailUpdateUrl)!)
                
                request2.httpMethod = ServiceTypeConstants.httpMethodPut
                request2.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request2.httpBody = requestParametersNew.stringFromHttpParameters().data(using: .utf8)
                let taskUser = URLSession.shared.dataTask(with: request2) { data, response, error in
                    // check for fundamental networking error
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let data = data, error == nil else {
                            print("error=\(error)")
                            return
                        }
                        
                        // check for http errors
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != ServiceTypeConstants.statusCodeOK {
                            print("Failed with status code: \(httpStatus.statusCode)")
                        }
                        
                        let responseString = String(data: data, encoding: .utf8)
                        if let data = responseString?.data(using: String.Encoding.utf8) {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                                    print("JSON Value...Update User")
                                    self?.parseJsonUser(json: json)
                                }
                            } catch {
                                // No-op
                            }
                            
                        }
                    }
                }
                
                let when2 = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when2 + 0.3) {
                    taskUser.resume()
                }
            }
        }
        print("Send Msg called with Request.Para.\(finalContent!)")
        
        
    }
    
    
    
    
    func serviceCallforLogin(withText textUser: String,and textPassword:String) {
        print("Send Msg called")
       
       // print("Send Msg called with text..\(textUser,textPassword)")
        
        
        let requestParameters =
            [BodyKey.username: textUser,
             BodyKey.password: textPassword
        ]
        
        var request = URLRequest(url: URL(string: GlobalConstants.logInAuthenticationUrl)!)
        request.httpMethod = ServiceTypeConstants.httpMethodPost
        request.httpBody = requestParameters.stringFromHttpParameters().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // check for fundamental networking error
            DispatchQueue.main.async { [weak self] in
                
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != ServiceTypeConstants.statusCodeOK {
                    print("Failed with status code: \(httpStatus.statusCode)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                if let data = responseString?.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            print("JSON Value.LogIn..\(json)")
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
    

    
    func serviceCallforGettingProfile(With id:String) {
        
        print("Send Msg called")
        
        let urlStr = String(format: GlobalConstants.getProfileData, id)
        
        var request3 = URLRequest(url: URL(string: urlStr)!)
        request3.httpMethod = "GET"//ServiceTypeConstants.httpMethodGet
        let taskUser = URLSession.shared.dataTask(with: request3) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                    
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode !=
                    ServiceTypeConstants.statusCodeOK {
                }
                
                let responseString = String(data: data, encoding: .utf8)
                if let data = responseString?.data(using: String.Encoding.utf8) {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            self?.parseJsonProfile(json: json)
                        }
                        
                    } catch {
                        
                    }
                    
                }
            }
        }
        let when2 = DispatchTime.now()
        
        DispatchQueue.main.asyncAfter(deadline: when2 + 0.3) {
            taskUser.resume()
            
        }
        
        
    }
    
    func getUserAccessTokenForBox() {
        let urlStr = String(format: GlobalConstants.userTokenUrl)
        var request3 = URLRequest(url: URL(string: urlStr)!)
        request3.httpMethod = "GET"//ServiceTypeConstants.httpMethodGet
        let taskUser = URLSession.shared.dataTask(with: request3) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                    
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode !=
                    ServiceTypeConstants.statusCodeOK {
                }
                
                let responseString = String(data: data, encoding: .utf8)
                if let data = responseString?.data(using: String.Encoding.utf8) {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            self?.parseJsonToken(json: json)
                        }
                        
                    } catch {
                        
                    }
                    
                }
            }
        }
        let when2 = DispatchTime.now()
        
        DispatchQueue.main.asyncAfter(deadline: when2 + 0.3) {
            taskUser.resume()
            
        }
    }
    
    
    func getAccessTokenForBox() {
       
        var headerBase64 = ""
        var claimBase64 = ""
        var signatureBase64 = ""
        var headerData: Data? = nil
        var claimData: Data? = nil
        let headerValue = [
            BodyKey.alg : GlobalConstants.algValue,
            BodyKey.type : GlobalConstants.typeValue,
            BodyKey.kid : GlobalConstants.kidValue
        ]
        
        let timestamp = Int64(Date().timeIntervalSince1970+45)
        print(timestamp)
        
        let claimValue =
            [BodyKey.iss: GlobalConstants.issValue,
             BodyKey.sub: GlobalConstants.sub,
             BodyKey.box_sub_type : GlobalConstants.boxSubType,
             BodyKey.aud : GlobalConstants.audValue,
             BodyKey.jti : GlobalConstants.jtiValue,
             BodyKey.exp : 1428699385//1497982931//Int(timestamp)
        ] as [String : Any]
        
        let signatureValue = GlobalConstants.clientSecret
        let signatureData = signatureValue.data(using: String.Encoding.utf8)!
        signatureBase64 = self.base64ToBase64url(base64: signatureData.base64EncodedString())
        
        do {
            headerData = try! JSONSerialization.data(withJSONObject:headerValue,options: JSONSerialization.WritingOptions.prettyPrinted)
            headerBase64 = self.base64ToBase64url(base64: (headerData?.base64EncodedString())!)
        }
        do {
            claimData = try! JSONSerialization.data(withJSONObject:claimValue,options: JSONSerialization.WritingOptions.prettyPrinted)
            claimBase64 = self.base64ToBase64url(base64: (claimData?.base64EncodedString())!)
        }
        
//        var claims = ClaimSet()
//        claims.issuer = "fuller.li"
//        claims.issuedAt = Date()
//        claims["custom"] = "Hi"
//        
        //let data =
        //JWT.encode(claims: claims, algorithm: .hs256("secret".data(using: .utf8)))
        let dataVL = JWT.encode(claims:claimValue, algorithm: .hs256("secret".data(using: .utf8)!))
        print("my JSON pod...\(dataVL)")
        //let publicKey =  "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1J4WoBXAAybnLmu6QVUILREVJAFqVG9Hbcm7E18Ba6Y53LTy6liKNnuDjw9OOfJcuPk2whmGEyraf6U4TqgoBk39/Dnhj1Gj6mHUezdoehKZ7CfcBX5aUhyvnhkLG55pWTwEHcetsD+zzjuUZjnhaFJ1tjr5din3NCK58GBSJoHszwDqoDSSDRi99QEmCkSxr0Hf6n8dj0qNLbeDTlM5/bQomrDzj37wrQGVPS+5TQZXDLp3qApSNqYTsVZUV3lJaVNAKGmpSLRj7g36v23I7YfaT2laJ/DRmXdPeCs/KRQmiKXUnLKcZXu9S6K+u0EVzwnDHKA9TlKiuQLTWnwi6QIDAQAB"
        
        //let privateKey = "\nMIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDgQIa2EMu0IJHZICAggA\nMBQGCCqGSIb3DQMHBAi/YR96Dyp1CgSCBMgax1YYpo4qIePaTt0HB61rKh92KczL\nkdCpjVyoOGTKZrobTMR+sUYdiQr3TXMgoIekM1l7oaWCUGJ86AN9Px8+JTG46xIF\nW4uIBxAdVDD3xx0nILU1KzxSZTVNNsdMAj81429Q14QqyEQqiIDeGLdAhsYkRknw\npPClqygZ5STnk9zfO9j8naRIsZ3uPWqOrJWfGJ+Ou8cqk0tL3RS6qEnNhmB8mJc2\n/Pamj6FgFIiXCxtwQkblExQk3FJK32d8g2nD0CyqQtsDXMIvgMoGN8Qwv8fbuS0y\nZDxrae8jipGcPcGpWBN6rAsJK6m2S7va3JN6ehip07lWrTfmhNoXkKdQhOU/sicK\nkV6y/ah6xFh5spre4o4JPftMqgYBOWG6i6A2krrqzMzbUMBZI/hJfsw86Z3oZOtM\nJUzAyThfP2jb03TznaH/k0GS+msORZ/jCbY71D7VrUqEsC6tCZtdbGXzdXn4ZT7i\nB1zGYuMvchOrNdAnfIpGMvcXjCrY0h49LoRs6By1IbErEbPSKwnXOB68I+nJwZq9\nc6G3tN1fV1gnCCTsgPLYIMygNWJAZ5d3UP8+98i1qSLM9CDqaO/nmRq/q8PgVkx0\n/pb8xUWEKv13pp/9Hq043vTbnMd+qrB1au7X9LFEKxLsJBQL1b2ZL3vI51LjQhDQ\ncbiC1LvZ1G7kbgQ8L158CEoQddxDm6GVN0lDEgZ8lSIPcmASyyv/ivIh9T6V8mND\nYFG89uJhpcXNvnxS+inlmnbr12mjIOSi6Cwkt496vdtgu1Bj1Z4YrK4+pro8LkuP\nCgLG80oq2TsdcsaGUOGGTJbVqvLJM0ki4rdNsyWAgBMtdeZv4agyfkHCCzfTNWf8\nII42P+puCnWbE2V+xy1yzh775Asb2633Xc8nNIkCrxuxisRe1CSouKmOnqn7G7fa\nUlzvLfpoQ6Yer5bnGjqtQhyEu5pnSRU8PPPt1Hyd/oMd+0oC3TrCXuCJf93udJ0A\nNktPX85VbD5xhF57N1W9IfjdKjR8WUcbxU+N/cHjZf1bssSKlaQLAioClht/YhOq\nZ6KDNGj8ULhUEJhhUofQmk+z8cwOllI+GDrKBLutQxAMmWZ7xcQD0K+zmVMyB4Fr\n2dAmzYwHVYotmYGeDhrcHev0ENTz3Wb5US16WFmXC3BRKoBtpfvi4CpjuQuWJEoz\nP542bUBWstZ0Xc7zFYKlyRfhOyUQfcw1911TmIS/DFu74NAB688wcX6a6940s6i5\n+tMGqtNJKrv5BMLrzLXm/9pFlUvmcoCFPvQtMvCG/oOeU2BEmfD4qyyXHJJdJfP1\nIrOwUZLj+/Pdgjh3JeRC5egyiCbQ5P7qaNAv6NWfm2oZiOnEZkm77Vb6U5is7S8P\nya/98i3DNC+13gZszlr4ZnmOHghAlE5IXuRYO2FQPIDZaWuK2RrJYCxQTTjyDtjJ\nFCMtKsWEVKVEVU3dVJsCZisRTNJs63hmLDXzSu7ItUZZBCdd9Lj38LfmSAQingpZ\nErKT3TwkwiOv1A8YzbJvNM1SYnFml1Mm4h+X0Zx7zg5RlSII6tcQ+sCO7oVfy8Od\ng64GmLqrG5WU4t9msw25MjfrQcWFRBE26wN/p6CdLz5TAt6XMqPPCdM5xNuOFgTH\necE=\n"
        
        //5xCJXqmPgliUNZbFCd87R859d1OURER2
        let data = headerBase64 + "." + claimBase64
        let dataValue = data.hmac(algorithm: .SHA256, key: "secret")//"5xCJXqmPgliUNZbFCd87R859d1OURER2")//data.digestHMac256(key: "5xCJXqmPgliUNZbFCd87R859d1OURER2")
        
        //let signature = hmac(string: "secret", key: dataValue as NSData)//( data, GlobalConstants.clientSecret);
        
        
        //HMACSHA256(encodedString, "secret")
        
        
        //let signatureStr = self.base64ToBase64url(base64: publicKey)
        //print(signatureStr)
        let assertionValue = String(format : "%@.%@.%@",headerBase64,claimBase64,dataValue)
        //print(assertionValue)
        
        let requestParameters = [
            BodyKey.grant_type : GlobalConstants.grantType,
            BodyKey.clientId : GlobalConstants.issValue,
            BodyKey.clientSecret : GlobalConstants.clientSecret,
            BodyKey.assertionValue :assertionValue
            
        ]

        var request = URLRequest(url: URL(string: GlobalConstants.tokenUrl)!)
        
        request.httpMethod = ServiceTypeConstants.httpMethodPost
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestParameters.stringFromHttpParameters().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                
                guard let data = data, error == nil else {
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode !=  ServiceTypeConstants.statusCodeOK {
                    // print("Failed with status code: \(httpStatus.statusCode)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                if let data = responseString?.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            print("JSON Value...\(json)")
                            self?.parseJsonToken(json: json)
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
    
    
    func base64ToBase64url(base64: String) -> String {
        let base64url = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }
    
//    private func hmac(string: NSString, key: NSData) -> NSData {
//        let keyBytes = key.bytes.assumingMemoryBound(to: CUnsignedChar.self)
//        //let keyBytes = UnsafePointer<CUnsignedChar>(key.bytes)
//        let data = string.cString(using: String.Encoding.utf8.rawValue)
//        let dataLen = Int(string.lengthOfBytes(using: String.Encoding.utf8.rawValue))
//        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, key.length, data, dataLen, result);
//        return NSData(bytes: result, length: digestLen)
//    }
    
    
    func parseJsonProfile(json: [String:AnyObject]) {
        
        //self.value = json["docs"] as! [String]
            let text = (json)
         self.delegate?.didReceiveMessage(withText: text)
        
    }
    
    
    
    
    
    func parseJsonToken(json: [String:AnyObject]) {
        print(json)
        if let text = json["access_token"] as? String{
           // print(text )
            self.delegate?.didReceiveMessage(withText:text)
        }
        
    }
    
    func parseJson(json: [String:AnyObject]) {
        
        //self.value = json["docs"] as! [String]
        let text = json["docs"] as? NSArray
        self.delegate?.didReceiveMessage(withText:text ?? "")
        
    }
    
    func parseJsonUser(json: [String:AnyObject]) {
        print(json)
        if let text = json["ok"] as? Bool{
            self.delegate?.didReceiveMessage(withText:text)
        }else{
            self.delegate?.didReceiveMessage(withText:false)
        }
        
        
    }


}


extension String {
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
    
}



extension String {
    
    func digestHMac256(key: String) -> String! {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = self.lengthOfBytes(using: String.Encoding.utf8)
        
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<Any>.allocate(capacity: digestLen)
        
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = key.lengthOfBytes(using: String.Encoding.utf8)
        
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        
        CCHmac(algorithm, keyStr!, keyLen, str!, strLen, result)
        
        let data = NSData(bytesNoCopy: result, length: digestLen)
        
        let hash = data.base64EncodedString()
        
        return hash
    }
}



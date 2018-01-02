//
//  Settings.swift
//  WatsonDemo
//
//  Created by RAHUL on 3/27/17.
//  Copyright © 2017 RAHUL. All rights reserved.
//

import Foundation



class ProfileModel
{
    //var sId : NSNumber
    var lastName : String
    var profileImage : String
    var firstName : String
    var phoneNumber : String
    var email : String
    var policyNumber : String
    var voiceValue : String
    var agencyName : String
    
    
    init(lastName:String,profileImage:String,firstName:String,email:String,phoneNumber:String,policyNumber:String,voiceValue:String,agencyName:String)
    {
        //self.sId = sId
        self.lastName=lastName
        self.profileImage=profileImage
        self.firstName = firstName
        self.email = email
        self.phoneNumber = phoneNumber
        self.policyNumber = policyNumber
        self.voiceValue = voiceValue
        self.agencyName = agencyName
        
    }
    
    
    static func createDataForPeopleView(_ featuresDataJson:NSMutableArray) -> [ProfileModel]
    {
        print(">>>>>>>>>>\(featuresDataJson)")
        var ProfileModelData : [ProfileModel]=[]
        for  i in 0 ..< featuresDataJson.count {
            let featuresDataArray = featuresDataJson[i]
            print(">>>>>>>>>>\(featuresDataArray)")
            do {
                
                
                let featuresData =
                    
                    ProfileModel(lastName:(featuresDataArray as AnyObject).value(forKey: "preferredlastname")! as! String,profileImage:"",firstName:(featuresDataArray as AnyObject).value(forKey: "preferredfirstname")! as! String,email:(featuresDataArray as AnyObject).value(forKey: "email")! as! String,phoneNumber:(featuresDataArray as AnyObject).value(forKey: "cellphonenumber")! as! String,policyNumber:(featuresDataArray as AnyObject).value(forKey: "policynumber")! as! String,voiceValue:(featuresDataArray as AnyObject).value(forKey: "voice")! as! String,agencyName: "")
                ProfileModelData.append(featuresData)
                
                //(featuresDataArray as AnyObject).value(forKey: "agency") as! String
            }
        }
        return ProfileModelData
        
    }
    
}

class distributionListModel
{
    
    //var sId : NSNumber
    var lastName : String
    var firstName : String
    var phoneNumber : String
    var email : String
    
    
    init(lastName:String,firstName:String,email:String,phoneNumber:String)
    {
        //self.sId = sId
        self.lastName=lastName
        self.firstName = firstName
        self.email = email
        self.phoneNumber = phoneNumber
        
    }
    
    
    static func createDataForPeopleView(_ featuresDataJson:NSMutableArray) -> [distributionListModel]
    {
        var distributionListData : [distributionListModel]=[]
        for  i in 0 ..< featuresDataJson.count {
            let featuresDataArray = featuresDataJson[i]
            do {
                let featuresData =
                    distributionListModel(lastName:(featuresDataArray as AnyObject).value(forKey: "lastname")! as! String,firstName:(featuresDataArray as AnyObject).value(forKey: "firstname")! as! String,email:(featuresDataArray as AnyObject).value(forKey: "email")! as! String,phoneNumber:(featuresDataArray as AnyObject).value(forKey: "cellphone")! as! String)
                distributionListData.append(featuresData)
            }
        }
        return distributionListData
        
    }
    
}


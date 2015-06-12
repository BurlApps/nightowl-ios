//
//  Settings.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

var updating = false
var isInRelease = false

class Settings: NSObject {
    
    // MARK: Instance Variables
    var itunesId: String!
    var host: String!
    var supportUrl: String!
    var termsUrl: String!
    var privacyUrl: String!
    var venmo: String!
    var freeQuestions: Int!
    var freeQuestionsCard: Int!
    var referralQuestions: Int!
    var parse: PFConfig!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFConfig) {
        self.init()
        
        self.itunesId = object["itunesId"] as? String
        self.host = object["host"] as? String
        self.supportUrl = object["supportUrl"] as? String
        self.termsUrl = object["termsUrl"] as? String
        self.privacyUrl = object["privacyUrl"] as? String
        self.venmo = object["venmo"] as? String
        self.freeQuestions = object["freeQuestions"] as? Int
        self.referralQuestions = object["referralQuestions"] as? Int
        self.freeQuestionsCard = object["freeQuestionsCard"] as? Int
        self.parse = object
    }
    
    // MARK: Class Methods
    class func setRelease(data: Bool) {
        isInRelease = data
    }
    
    class func getRelease() -> Bool {
        return isInRelease
    }
    
    class func sharedInstance(callback: ((settings: Settings) -> Void)!) {
        let config = PFConfig.currentConfig()
        
        if !updating && config["host"] != nil {
            callback?(settings: Settings(config))
        } else {
            Settings.update(callback)
        }
    }
    
    class func update(callback: ((settings: Settings) -> Void)!) {
        updating = true
        
        PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
            updating = false
            
            if config != nil {
                callback?(settings: Settings(config!))
            } else {
                callback?(settings: Settings(PFConfig.currentConfig()))
            }
        }
    }
}

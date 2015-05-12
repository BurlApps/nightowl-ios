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
    var host: String!
    var supportUrl: String!
    var termsUrl: String!
    var privacyUrl: String!
    var freeQuestions: Int!
    var freeQuestionsCard: Int!
    var questionPrice: Float!
    var referralQuestions: Int!
    var parse: PFConfig!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFConfig) {
        self.init()
        
        self.host = object["host"] as? String
        self.supportUrl = object["supportUrl"] as? String
        self.termsUrl = object["termsUrl"] as? String
        self.privacyUrl = object["privacyUrl"] as? String
        self.freeQuestions = object["freeQuestions"] as? Int
        self.referralQuestions = object["referralQuestions"] as? Int
        self.freeQuestionsCard = object["freeQuestionsCard"] as? Int
        self.questionPrice = object["questionPrice"] as? Float
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
    
    // MARK: Instance Variables
    func priceFormatted() -> String {
        if self.questionPrice == 0 {
            return "Free"
        } else if self.questionPrice < 1 {
            return String(format: "%.0f¢", self.questionPrice*100)
        } else {
            return String(format: "$%.2f", self.questionPrice)
        }
    }
}

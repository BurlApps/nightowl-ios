//
//  Settings.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Settings: NSObject {
    
    // MARK: Instance Variables
    var host: String!
    var freeQuestions: Int!
    var questionNameLimit: Int!
    var parse: PFConfig!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFConfig) {
        self.init()
        
        self.host = object["host"] as String
        self.freeQuestions = object["freeQuestions"] as Int
        self.questionNameLimit = object["questionNameLimit"] as Int
        self.parse = object
    }
    
    // MARK: Class Methods
    class func sharedInstance(callback: ((settings: Settings) -> Void)!) {
        if let config = PFConfig.currentConfig() {
            callback?(settings: Settings(config))
        } else {
            Settings.update(callback)
        }
    }
    
    class func update(callback: ((settings: Settings) -> Void)!) {
        PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig!, error: NSError!) -> Void in
            if error == nil && config != nil {
                callback?(settings: Settings(config))
            } else if var config = PFConfig.currentConfig() {
                callback?(settings: Settings(config))
            }
        }
    }
}

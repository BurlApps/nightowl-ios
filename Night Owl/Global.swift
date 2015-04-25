//
//  Global.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/2/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

var window: UIWindow!

class Global {
    
    class func setWindow(tempWindow: UIWindow!) {
        window = tempWindow
    }
    
    class func topViewController(index: Int) -> UIViewController? {
        let pagesController = window?.rootViewController as? PagesController
        return pagesController!.controllers[index]?.topViewController
    }

    class func reloadQuestionsController() {
        (Global.topViewController(0) as? QuestionsController)?.reloadQuestions()
    }
    
    class func reloadSettingsController() {
        (Global.topViewController(2) as? SettingsController)?.reloadUser()
    }
}

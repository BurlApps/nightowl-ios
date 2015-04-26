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
    
    class func viewControllers() -> [Int: PageController] {
        let pagesController = window?.rootViewController as? PagesController
        return pagesController!.controllers
    }

    class func reloadQuestionsController() {
        for (index, parent) in self.viewControllers() {
            if let controller = parent.topViewController as? QuestionsController {
                controller.reloadQuestions()
            }
        }
    }
    
    class func reloadSettingsController() {
        for (index, parent) in self.viewControllers() {
            if let controller = parent.topViewController as? SettingsController {
                controller.reloadUser()
            }
        }
    }
    
    class func supportMessage(text: String) {
        for (index, parent) in self.viewControllers() {
            if let controller = parent.topViewController as? SupportController {
                controller.recievedMessage(text)
            }
        }
    }
}

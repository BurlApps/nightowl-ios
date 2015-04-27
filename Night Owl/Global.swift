//
//  Global.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/2/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Global {
    
    // MARK: Instance Variables
    static var window: UIWindow!
    
    // MARK: Class Methods
    class func viewControllers() -> [Int: PageController] {
        let pagesController = window?.rootViewController as? PagesController
        return pagesController!.controllers
    }
    
    class func slideToController(index: Int, animated: Bool, direction: UIPageViewControllerNavigationDirection) {
        let pagesController = window?.rootViewController as? PagesController
        pagesController?.setActiveChildController(index, animated: animated, direction: direction)
    }
    
    class func lockPageView() {
        let pagesController = window?.rootViewController as? PagesController
        pagesController?.lockPageView()
    }
    
    class func unlockPageView() {
        let pagesController = window?.rootViewController as? PagesController
        pagesController?.unlockPageView()
    }
    
    class func cameraController(start: Bool) {
        for (index, parent) in self.viewControllers() {
            if let controller = parent.topViewController as? CameraController {
                if start {
                    controller.cameraView.start()
                } else {
                    controller.cameraView.stop()
                }
            }
        }
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
    
    class func reloadSupportController() {
        for (index, parent) in self.viewControllers() {
            if let controller = parent.topViewController as? SupportController {
                controller.reloadMessages()
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

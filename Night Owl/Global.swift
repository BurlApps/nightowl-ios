//
//  Global.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/2/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Global {
    
    // MARK: Instance Variables
    static var pagesController: PagesController!
    
    // MARK: Class Methods
    class func appBuildVersion() -> String {
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as! NSString
        let build = infoDictionary[kCFBundleVersionKey] as! NSString
    
        return "\(version) - \(build)"
    }
    
    class func appVersion() -> String {
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        
        return infoDictionary["CFBundleShortVersionString"] as! String
    }
    
    class func slideToController(index: Int, animated: Bool, direction: UIPageViewControllerNavigationDirection) {
        pagesController?.unlockPageView()
        pagesController?.setActiveChildController(index, animated: animated, direction: direction)
    }
    
    class func lockPageView() {
        pagesController?.lockPageView()
    }
    
    class func unlockPageView() {
        pagesController?.unlockPageView()
    }
    
    class func cameraController(start: Bool) {
        for (index, parent) in self.pagesController.controllers {
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
        for (index, parent) in self.pagesController.controllers {
            if let controller = parent.topViewController as? QuestionsController {
                controller.reloadQuestions()
            }
        }
    }
    
    class func reloadSettingsController() {
        for (index, parent) in self.pagesController.controllers {
            if let controller = parent.topViewController as? SettingsController {
                controller.reloadUser()
            }
        }
    }
    
    class func reloadSupportController() {
        for (index, parent) in self.pagesController.controllers {
            if let controller = parent.topViewController as? SupportController {
                controller.reloadMessages()
            }
        }
    }
    
    class func supportMessage(text: String) {
        for (index, parent) in self.pagesController.controllers {
            if let controller = parent.topViewController as? SupportController {
                controller.recievedMessage(text)
            }
        }
    }
    
    class func showInvite(source: String) {
        self.pagesController.showInvite(source)
    }
    
    class func configureMaveShare() {
        var mave = MaveSDK.sharedInstance()
        
        // Create Cancel/Back Button
        var button = UIBarButtonItem()
        button.title = "Cancel"
        button.tintColor = UIColor.blackColor()
        
        // Navigation bar options
        mave.displayOptions.statusBarStyle = UIStatusBarStyle.Default
        mave.displayOptions.navigationBarTitleCopy = "Invite Friends"
        mave.displayOptions.navigationBarTitleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
        mave.displayOptions.navigationBarTitleTextColor = UIColor(red:0.25, green:0.29, blue:0.33, alpha:1)
        mave.displayOptions.navigationBarCancelButton = button
        
        // Invite options
        mave.displayOptions.inviteExplanationFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        mave.displayOptions.inviteExplanationTextColor = UIColor.whiteColor()
        mave.displayOptions.inviteExplanationCellBackgroundColor = UIColor(red:0.21, green:0.73, blue:0.76, alpha:1)
        mave.displayOptions.inviteExplanationShareButtonsColor = UIColor(red:0.25, green:0.29, blue:0.33, alpha:1)
        mave.displayOptions.inviteExplanationShareButtonsFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        mave.displayOptions.inviteExplanationShareButtonsBackgroundColor = UIColor(red:0.21, green:0.73, blue:0.76, alpha:1)
        
        // Message and Send section options for invite page v1
        mave.displayOptions.messageFieldFont = UIFont.systemFontOfSize(16)
        mave.displayOptions.messageFieldTextColor = UIColor(red:0.25, green:0.29, blue:0.33, alpha:1)
        mave.displayOptions.messageFieldBackgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1)
        mave.displayOptions.sendButtonCopy = "Send"
        mave.displayOptions.sendButtonFont = UIFont(name: "HelveticaNeue-Bold", size: 20)
        mave.displayOptions.sendButtonTextColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
        mave.displayOptions.bottomViewBorderColor = UIColor(red:0, green:0, blue:0, alpha:0.15)
        mave.displayOptions.bottomViewBackgroundColor = UIColor(red:0.98, green:0.99, blue:0.99, alpha:1)
        mave.displayOptions.contactInlineSendButtonFont = UIFont(name: "HelveticaNeue-Bold", size: 20)
        mave.displayOptions.contactInlineSendButtonTextColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
        mave.displayOptions.contactInlineSendButtonDisabledTextColor = UIColor.grayColor()

        // Contacts table options
        mave.displayOptions.contactCheckmarkColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
        
        // The client-side share page (the fallback if the normal
        // invite page can't be displayed)
        mave.displayOptions.sharePageBackgroundColor = UIColor(red:0.98, green:0.99, blue:0.99, alpha:1)
        mave.displayOptions.sharePageIconColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
        mave.displayOptions.sharePageIconFont = UIFont(name: "HelveticaNeue", size: 14)
        mave.displayOptions.sharePageIconTextColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
        mave.displayOptions.sharePageExplanationFont = UIFont(name: "HelveticaNeue-Bold", size: 24)
        mave.displayOptions.sharePageExplanationTextColor = UIColor(red:0.22, green:0.6, blue:0.59, alpha:1)
    }
}

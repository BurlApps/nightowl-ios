//
//  AppDelegate.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/21/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        //Initialize Parse
        let parseApplicationID = infoDictionary["ParseApplicationID"] as! String
        let parseClientKey = infoDictionary["ParseClientKey"] as! String
        ParseCrashReporting.enable()
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Initialize Stripe
        let stripeKey = infoDictionary["StripeClientKey"] as! String
        Stripe.setDefaultPublishableKey(stripeKey)
        
        // Initialize Mave
        let maveKey = infoDictionary["MaveClientKey"] as! String
        MaveSDK.setupSharedInstanceWithApplicationID(maveKey)
        Global.configureMaveShare()
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let notificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
            // Register for Push Notifications before iOS 8
        } else {
            let notificationTypes = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(notificationTypes)
        }
        
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload = (launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] == nil)
            
            if preBackgroundPush || oldPushHandlerOnly || noPushPayload {
                Track.appOpened(launchOptions)
            }
        }
        
        // Cache Settings
        Settings.update(nil)
        
        // Cache Subjects
        Subject.subjects(false, callback: nil)
        
        // Configure Settings Panel
        let buildType = infoDictionary["BuildType"] as! String
        let version = infoDictionary["CFBundleShortVersionString"] as! NSString
        let build = infoDictionary[kCFBundleVersionKey] as! NSString
        var versionBuild = "\(version) (\(build))" as NSString
        let previousVersionBuild = userDefaults.objectForKey("VersionNumber") as? NSString
        var devBuild = false
        
        if buildType == "debug" {
            versionBuild = (versionBuild as String) + " - Debug"
            devBuild = true
        }
        
        if devBuild && versionBuild != previousVersionBuild {
            User.logout()
        }
        
        Settings.setRelease(!devBuild)
        userDefaults.setValue(versionBuild, forKey: "VersionNumber")
        userDefaults.synchronize()

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Installation.current().setDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        var wasActive = true
        
        if application.applicationState == UIApplicationState.Inactive {
            Track.appOpenedFromNotification(userInfo)
            wasActive = false
        }
        
        if let tempAction = userInfo["action"] as? String {
            var actions = tempAction.componentsSeparatedByString(",")
            
            for (var action) in actions {
                var title = userInfo["title"] as? String
                var message = userInfo["message"] as? String
                
                action = action.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                switch(action) {
                    case "questionsController.reload":
                        if(!wasActive) {
                            Global.slideToController(1, animated: false, direction: .Reverse)
                        }
                    
                        Global.reloadQuestionsController()
                    case "settingsController.reload":
                        Settings.update(nil)
                        Global.reloadSettingsController()
                    case "settings.reload": Settings.update(nil)
                    case "user.reload": User.current().fetch(nil)
                    case "user.rate": Global.showRateApp()
                    case "user.message":
                        if(title != nil && message != nil) {
                            Global.showAlert(title!, message: message!)
                        }
                    case "subjects.reload": Subject.subjects(false, callback: nil)
                    case "support.message":
                        if(message != nil) {
                            Global.supportMessage(message!, wasActive: wasActive)
                        }
                    default: println(action)
                }
            }
        }
        
        Installation.current().clearBadge()
        completionHandler(UIBackgroundFetchResult.NewData)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Global.reloadSupportController()
        Installation.current().clearBadge()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        Installation.current().clearBadge()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if DebugAccount.alternateDebug() {
            User.logout()
        }
    }
}


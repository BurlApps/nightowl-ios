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
        let parseApplicationID = infoDictionary["ParseApplicationID"] as String
        let parseClientKey = infoDictionary["ParseClientKey"] as String
        
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
        
        // Register for Push Notitications
        let userNotificationTypes = (UIUserNotificationType.Alert |
            UIUserNotificationType.Badge |
            UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Track User Open
        Track.appOpened(launchOptions)
        
        // Cache Settings
        Settings.update(nil)
        
        // Cache Subjects
        Subject.subjects(false, nil)
        
        // Configure Settings Panel
        let buildType = infoDictionary["BuildType"] as String
        let version = infoDictionary["CFBundleShortVersionString"] as NSString
        let build = infoDictionary[kCFBundleVersionKey] as NSString
        var versionBuild = "\(version) (\(build))" as NSString
        let previousVersionBuild = userDefaults.objectForKey("VersionNumber") as? NSString
        var devBuild = false
        
        if buildType == "debug" {
            versionBuild = versionBuild + " - Debug"
            devBuild = true
        }
        
        if devBuild && versionBuild != previousVersionBuild {
            User.logout()
        }
        
        userDefaults.setValue(versionBuild, forKey: "VersionNumber")
        userDefaults.synchronize()

        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Installation.current().setDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Inactive {
            // The application was just brought from the background to the foreground,
            // so we consider the app as having been "opened by a push notification."
            Track.appOpenedFromNotification(userInfo)
        }
        
        if let action = userInfo["action"] as? String {
            let pagesController = window?.rootViewController as PagesController
            
            switch(action) {
                case "questionsController.reload": (pagesController.controllers[0]?.topViewController as? QuestionsController)?.reloadQuestions()
                case "settingsController.reload": (pagesController.controllers[2]?.topViewController as? SettingsController)?.reloadUser()
                case "settings.reload": Settings.update(nil)
                default: println(action)
            }
        }
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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


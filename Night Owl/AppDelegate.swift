//
//  AppDelegate.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/21/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Initialize Parse
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId("0bzu64ADBGuHKglFYiCTYKR7tFZVaepLxVT1HXYe", clientKey: "1VcBDc3O8TogJPqCbiZbfz9zezfI9HaYSHKgRLvG")
        
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
            let rootController = window?.rootViewController as RootController
            
            switch(action) {
                case "questions.reload": (rootController.pagesControllers[0]?.topViewController as? QuestionsController)?.reloadQuestions()
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


//
//  Notifications.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/12/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class Notifications: NSObject {
    
    var enabled = false
    var application = UIApplication.sharedApplication()
    
    override init() {
        if self.application.respondsToSelector(Selector("isRegisteredForRemoteNotifications")) {
            self.enabled = self.application.isRegisteredForRemoteNotifications()
        }  else {
            self.enabled = self.application.enabledRemoteNotificationTypes() != .None
        }
    }
    
    func register() {
        if self.application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let notificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            self.application.registerUserNotificationSettings(settings)
            self.application.registerForRemoteNotifications()
        } else {
            let notificationTypes = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            self.application.registerForRemoteNotificationTypes(notificationTypes)
        }
    }
}

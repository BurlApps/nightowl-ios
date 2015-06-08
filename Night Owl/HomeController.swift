//
//  HomeController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/5/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class HomeController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {

    // MARK: Enum
    enum AlertState {
        case Referral, PromoCode, None
    }
    
    // MARK: Instance Variables
    var application = UIApplication.sharedApplication()
    private var currentPage = 0
    private var user: User!
    private var controllers: [HomePageController] = []
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Page Controller
        var imageView = UIImageView(frame: self.view.frame)
        
        imageView.image = UIImage(named: "Background")
        imageView.alpha = 0.04
        imageView.contentMode = .ScaleAspectFill
        
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:1)
        self.view.insertSubview(imageView, atIndex: 0)
        
        self.dataSource = self
        self.delegate = self
        
        for controller in self.view.subviews {
            if let scrollView = controller as? UIScrollView {
                scrollView.scrollEnabled = false
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        // Clear Controllers
        self.controllers.removeAll(keepCapacity: false)
        
        // Login Controller
        if let user = User.current() {
            self.user = user
            self.user.becomeUser()
        } else {
            self.createPage("HomeLoginController")
        }
        
        // Check If Notifications Are Enabled
        var notificationsEnabled: Bool
        
        if self.application.respondsToSelector(Selector("isRegisteredForRemoteNotifications")) {
            notificationsEnabled = self.application.isRegisteredForRemoteNotifications()
        }  else {
            notificationsEnabled = self.application.enabledRemoteNotificationTypes() != .None
        }
        
        if !notificationsEnabled {
            self.createPage("HomeNotificationsController")
        }
        
        // Check If Camera Is Enabled
        var cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if cameraStatus == .NotDetermined  {
            self.createPage("HomeCameraController")
        }
        
        // Check if Logged In
        if self.controllers.isEmpty {
            self.performSegueWithIdentifier("finishedSegue", sender: self)
        } else {
            self.showController()
        }
    }
    
    func createPage(name: String) {
        var page = self.storyBoard.instantiateViewControllerWithIdentifier(name) as? HomePageController
        
        page?.pageIndex = self.controllers.count
        page?.homeController = self
        
        self.controllers.append(page!)
    }
    
    func nextController() {
        self.currentPage += 1
        
        if self.currentPage >= self.controllers.count {
            self.currentPage = 0
            self.performSegueWithIdentifier("finishedSegue", sender: self)
        } else {
            self.showController()
        }
    }
    
    func showController() {
        if let controller = self.viewControllerAtIndex(self.currentPage) {
            self.setViewControllers([controller], direction: .Forward, animated: self.currentPage > 0, completion: nil)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> HomePageController! {
        if index == NSNotFound && index > self.controllers.count {
            return nil
        }
        
        return self.controllers[index]
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! HomePageController).pageIndex
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! HomePageController).pageIndex
        return self.viewControllerAtIndex(index + 1)
    }
}

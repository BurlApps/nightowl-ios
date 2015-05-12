//
//  ViewController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/21/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class PagesController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    // MARK: Instance Variables
    var controllers = Dictionary<Int, PageController>()
    private let onboardTime: NSTimeInterval = 4
    private let pages = 4
    private let startPage = 2
    private var currentPage = 2
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    private var onboarding: UIView!
    private var startDate = NSDate()
    private var scrollView: UIScrollView!
    private var inviteController: UINavigationController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Global
        Global.pagesController = self
        
        // Login User
        if let user = User.current() {
            user.identifyMave()
            user.fetch({ (user) -> Void in
                self.hideOnboarding()
            })
        } else {            
            User.register({ (user) -> Void in
                user.identifyMave()
                user.isReferral { (referred, credits) -> Void in
                    if referred {
                        UIAlertView(title: "You Are Awesome",
                            message: "You and your friend both get \(credits) more free questions for the referral!",
                            delegate: nil, cancelButtonTitle: "Okay").show()
                    }
                    
                    self.hideOnboarding()
                }
            })
        }
        
        // Onboard User
        self.onboarding = UIView(frame: self.view.frame)
        self.onboarding.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        // Create Onboarding Label
        var onboardLabel = UILabel(frame: CGRectMake(10, 10, self.view.bounds.width - 40, self.view.bounds.height - 40))
        onboardLabel.textAlignment = NSTextAlignment.Center
        onboardLabel.textColor = UIColor.whiteColor()
        onboardLabel.shadowColor = UIColor(white: 0, alpha: 0.2)
        onboardLabel.shadowOffset = CGSize(width: 0, height: 2)
        onboardLabel.font = UIFont(name: "HelveticaNeue", size: 22)
        onboardLabel.numberOfLines = 0
        onboardLabel.adjustsFontSizeToFitWidth = true
        
        var text = "Take a photo\nSend us a math question and we'll solve it.\n\n"
        text += "You get several answers (with steps) free on us. Enjoy!"
        
        var attributedText = NSMutableAttributedString(string: text)
        var style = NSMutableParagraphStyle()
        
        style.lineSpacing = 8
        style.alignment = .Center

        attributedText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedText.length))
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 30)!, range: NSMakeRange(0, 12))
        onboardLabel.attributedText = attributedText
        
        self.onboarding.addSubview(onboardLabel)
        self.view.addSubview(self.onboarding)
        
        // Create Page View Controller
        self.view.backgroundColor = UIColor.clearColor()
        self.dataSource = self
        self.delegate = self
        
        for controller in self.view.subviews {
            if let scrollView = controller as? UIScrollView {
                self.scrollView = scrollView
                self.scrollView.delegate = self
            }
        }
        
        // Create Controllers
        for index in 0...self.pages {
            var page: PageController!
            
            switch(index) {
            case 0: page = storyBoard.instantiateViewControllerWithIdentifier("SupportController") as? PageController
            case 1: page = storyBoard.instantiateViewControllerWithIdentifier("QuestionsController") as? PageController
            case 2: page = storyBoard.instantiateViewControllerWithIdentifier("CameraController") as? PageController
            default: page = storyBoard.instantiateViewControllerWithIdentifier("SettingsController") as? PageController
            }
            
            page?.view.frame = self.view.frame
            page?.pageIndex = index
            self.controllers[index] = page
        }
        
        self.didMoveToParentViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Remove Text From Back Button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000),
            forBarMetrics: UIBarMetrics.Default)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set Start Page
        self.setActiveChildController(self.startPage, animated: false, direction: .Forward)
    }
    
    // MARK: Instance Methods
    func showInvite(source: String) {
        var goToController = self.currentPage
        
        MaveSDK.sharedInstance().presentInvitePageModallyWithBlock({ (viewController: UIViewController!) -> Void in
            if let inviteController = viewController.childViewControllers[0] as? MAVEInvitePageViewController {
                self.inviteController = viewController as! UINavigationController
                
                self.inviteController.navigationBar.tintColor = UIColor.blackColor()
                inviteController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action,
                    target: self, action: Selector("additionalShare"))
            }
            
            self.presentViewController(viewController, animated: true, completion: { () -> Void in
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
            })
        }, dismissBlock: { (viewController: UIViewController!, numberOfInvitesSent: UInt) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                self.setActiveChildController(goToController, animated: false, direction: .Forward)
            })
        }, inviteContext: source)
    }
    
    func additionalShare() {
        var controller = MAVECustomSharePageViewController()
        var invite = self.inviteController.childViewControllers[0] as? MAVEInvitePageViewController
        
        self.inviteController.navigationBar.translucent = true
        self.inviteController.navigationBar.backgroundColor = UIColor.clearColor()
        self.inviteController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.inviteController.navigationBar.shadowImage = UIImage()
        self.inviteController.pushViewController(controller, animated: true)
    }
    
    func hideOnboarding() {
        var delay = self.onboardTime - NSDate().timeIntervalSinceDate(self.startDate)
        
        UIView.animateWithDuration(0.5, delay: max(delay, 0), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.onboarding.alpha = 0
        }) { (success:Bool) -> Void in
            self.onboarding.removeFromSuperview()
        }
    }
    
    func lockPageView() {
        self.scrollView.scrollEnabled = false
    }
    
    func unlockPageView() {
        self.scrollView.scrollEnabled = true
    }
    
    func setActiveChildController(index: Int, animated: Bool, direction: UIPageViewControllerNavigationDirection) {
        self.setViewControllers([self.viewControllerAtIndex(index)],
            direction: direction, animated: animated, completion: { (success: Bool) -> Void in
                self.currentPage = index
            })
    }
    
    func viewControllerAtIndex(index: Int) -> PageController! {
        if self.pages == 0 || index >= self.pages {
            return nil
        }
        
        return self.controllers[index]
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        if completed {
            self.currentPage = (pageViewController.viewControllers.last as! PageController).pageIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {        
        var index = (viewController as! PageController).pageIndex
        
        if index == NSNotFound || (index + 1) == self.pages {
            return nil
        }
        
        return self.viewControllerAtIndex(index + 1)
    }
    
    // MARK: UIScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        } else if self.currentPage == (self.pages - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        } else if self.currentPage == (self.pages - 1) && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        }
    }
}


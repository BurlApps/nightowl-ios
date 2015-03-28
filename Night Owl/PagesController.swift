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
    private let onboardTime: NSTimeInterval = 5
    private let pages = 3
    private let startPage = 1
    private var currentPage = 1
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    private var onboarding: UIView!
    private var startDate = NSDate()
    private var scrollView: UIScrollView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Login User
        if let user = User.current() {
            user.fetch({ (user) -> Void in
                self.hideOnboarding()
            })
        } else {            
            User.login({ (user) -> Void in
                self.hideOnboarding()
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
        
        var price = "Free"
        var text = "Take a photo\nSend us a math question and we'll solve it.\n\n"
        text += "Get a couple answers free on us, every question after you buy."
        
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
        
        // Create PageViewController
        var page = self.controllers[index]
        
        if page == nil {
            switch(index) {
            case 0: page = storyBoard.instantiateViewControllerWithIdentifier("QuestionsController") as? PageController
            case 1: page = storyBoard.instantiateViewControllerWithIdentifier("CameraController") as? PageController
            default: page = storyBoard.instantiateViewControllerWithIdentifier("SettingsController") as? PageController
            }
            
            page?.view.frame = self.view.frame
            page?.pageIndex = index
            page?.rootController = self
            self.controllers[index] = page
        }

        return page
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        if completed {
            self.currentPage = (pageViewController.viewControllers.last as PageController).pageIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as PageController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {        
        var index = (viewController as PageController).pageIndex
        
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
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, var withVelocity velocity: CGPoint, var targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            velocity = CGPointZero
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        } else if self.currentPage == (self.pages - 1) && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            velocity = CGPointZero
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        }
    }
}


//
//  ViewController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/21/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class RootController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    // MARK: Instance Variables
    var pagesControllers = Dictionary<Int, PageController>()
    private var pageViewController: UIPageViewController!
    private let pages = 3
    private let startPage = 1
    private var currentPage = 1
    private var locked = false
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.current() == nil {
            User.login(nil)
        }
        
        // Create Page View Controller
        self.pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.pageViewController.view.backgroundColor = UIColor.clearColor()
        self.pageViewController.view.frame = self.view.frame
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        for controller in self.pageViewController.view.subviews {
            if let scrollView = controller as? UIScrollView {
                scrollView.delegate = self
            }
        }
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
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
    func lockPageView() {
        self.locked = true
    }
    
    func unlockPageView() {
        self.locked = false
    }
    
    func setActiveChildController(index: Int, animated: Bool, direction: UIPageViewControllerNavigationDirection) {
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(index)],
            direction: direction, animated: animated, completion: { (success: Bool) -> Void in
                self.currentPage = index
            })
    }
    
    func viewControllerAtIndex(index: Int) -> PageController! {
        if self.pages == 0 || index >= self.pages {
            return nil
        }
        
        // Create PageViewController
        var page = self.pagesControllers[index]
        
        if page == nil {
            switch(index) {
            case 0: page = storyBoard.instantiateViewControllerWithIdentifier("QuestionsController") as? PageController
            case 1: page = storyBoard.instantiateViewControllerWithIdentifier("CameraController") as? PageController
            default: page = storyBoard.instantiateViewControllerWithIdentifier("SettingsController") as? PageController
            }
            
            page?.view.frame = self.view.frame
            page?.pageIndex = index
            page?.rootController = self
            self.pagesControllers[index] = page
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
        if (self.locked || (self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width)) {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        } else if (self.currentPage == (self.pages - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, var withVelocity velocity: CGPoint, var targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (self.locked || (self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width)) {
            velocity = CGPointZero
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        } else if (self.currentPage == (self.pages - 1) && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
            velocity = CGPointZero
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        }
    }
}


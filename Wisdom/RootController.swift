//
//  ViewController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/21/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource {

    // MARK: Instance Variables
    private var pageViewController: UIPageViewController!
    private let pages = 3
    private let startPage = 1
    private var pagesControllers = Dictionary<Int, PageController>()
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Page View Controller
        self.pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.pageViewController.view.backgroundColor = UIColor.clearColor()
        self.pageViewController.view.frame = self.view.frame
        self.pageViewController.dataSource = self
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(self.startPage)], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    // MARK: Instance Methods
    func viewControllerAtIndex(index: Int) -> PageController! {
        if self.pages == 0 || index >= self.pages {
            return nil
        }
        
        // Create PageViewController
        var page = self.pagesControllers[index]
        
        if page == nil {
            switch(index) {
            case 0: page = PageController(frame: self.view.frame, index: index)
            case 1: page = CameraController(frame: self.view.frame, index: index)
            default: page = PageController(frame: self.view.frame, index: index)
            }
            
            self.pagesControllers[index] = page
        }

        return page
    }
    
    // MARK: Page View Controller Data Source
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
}


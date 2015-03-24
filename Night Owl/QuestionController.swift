//
//  QuestionController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class QuestionController: UIViewController, UIScrollViewDelegate {
    
    // MARK: Instance Variable
    var question: Assignment!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Title
        let title = NSString(string: self.question.name)
        let length = min(15, title.length)
        self.title = title.substringToIndex(length)
        
        if title.length > 15 {
            self.title = self.title! + "..."
        }
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Create Loading Spinner
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.frame = CGRectMake(0, 0, 40, 40)
        spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        // Create Scroll View
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10
        self.view.addSubview(self.scrollView)
        
        // Create Image View
        self.imageView = UIImageView(frame: self.view.frame)
        self.scrollView.addSubview(self.imageView)
        
        // Download Answer
        question.getAnswer { (image) -> Void in
            self.imageView.image = image
            spinner.stopAnimating()
        }
    }
    
    // UIScrollView Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

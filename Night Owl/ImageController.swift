//
//  ImageController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/27/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ImageController: UIViewController, UIScrollViewDelegate {

    // MARK: Instance Variable
    var question: Assignment!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var user: User!
    var pageIndex: Int!
    var imageType: Assignment.ImageType!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create Loading Spinner
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.spinner.frame = CGRectMake(0, 0, 40, 40)
        self.spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        self.spinner.startAnimating()
        self.view.addSubview(self.spinner)
        
        // Create Scroll View
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10
        self.view.addSubview(self.scrollView)
        
        // Create Image View
        self.imageView = UIImageView(frame: CGRectMake(10, 10, self.view.frame.width-20, self.view.frame.height-20))
        self.scrollView.addSubview(self.imageView)
    }
    
    // MARK: Instance Methods
    func loadImage() {        
        self.question.getImage(self.imageType) { (image) -> Void in
            self.imageView.image = image
            self.spinner.stopAnimating()
        }
    }
    
    // MARK: UIScrollView Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

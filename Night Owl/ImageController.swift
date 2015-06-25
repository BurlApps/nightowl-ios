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
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create Loading Spinner
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.spinner.frame = CGRectMake(0, 0, 40, 40)
        self.spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        self.spinner.startAnimating()
        self.view.addSubview(self.spinner)
        
        // Create Scroll View
        self.scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10
        self.scrollView.clipsToBounds = true
        self.scrollView.scrollEnabled = true
        self.scrollView.bounces = true
        self.view.addSubview(self.scrollView)
        
        // Create Image View
        self.imageView = UIImageView(frame: self.view.frame)
        self.imageView.contentMode = .Center
        self.scrollView.addSubview(self.imageView)
        
        // Add Double Tap
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("doubleTap:"))
        tapGesture.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        self.loadImage()
    }
    
    // MARK: Instance Methods
    func loadImage() {        
        self.question.getImage(self.imageType) { (image) -> Void in
            let width = min(image.size.width, self.view.frame.width)
            let height = min(image.size.height, self.view.frame.height)
            let imageSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            
            self.imageView.image = RBResizeImage(image, imageSize)
            self.imageView.frame = CGRectMake(10, 10, width-20, height-20)
            self.spinner.stopAnimating()
        }
    }
    
    func doubleTap(recognizer: UIGestureRecognizer) {
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            var pointview = recognizer.locationInView(self.imageView)
            var newZoomscal: CGFloat = 3.0;
            
            newZoomscal = min(newZoomscal, self.scrollView.maximumZoomScale)
            
            var scrollViewSize = self.scrollView.bounds.size
            
            let w: CGFloat = scrollViewSize.width / newZoomscal
            let h: CGFloat = scrollViewSize.height / newZoomscal
            let x: CGFloat = pointview.x - (w/2.0)
            let y: CGFloat = pointview.y - (h/2.0)
            
            let rectTozoom: CGRect = CGRectMake(x, y, w, h)
            self.scrollView.zoomToRect(rectTozoom, animated: true)
            self.scrollView.setZoomScale(3, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    // MARK: UIScrollView Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

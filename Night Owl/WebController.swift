//
//  WebController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class WebController: UIViewController, UIWebViewDelegate {
    
    // MARK: Instance Variables
    var name: String!
    var website: String!
    private var spinner: UIActivityIndicatorView!
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Title
        self.title = self.name
        
        // Set WebView Url
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.website)!))
        
        // Add Spinner
        self.spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
        self.spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        self.spinner.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner)
    }
    
    // MARK: UIWebView Delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.spinner.stopAnimating()
    }
}

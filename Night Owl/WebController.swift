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
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set WebView Url
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.website)!))
    }
    
    // MARK: UIWebView Delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.title = self.name
    }
}

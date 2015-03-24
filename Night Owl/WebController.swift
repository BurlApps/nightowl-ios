//
//  WebController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class WebController: UIViewController {
    
    // MARK: Instance Variables
    var website: String!
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set WebView Url
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.website)!))
    }
}

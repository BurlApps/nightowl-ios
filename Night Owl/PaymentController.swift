//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/4/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PaymentController: UITableViewController, ApplePayDelegate {
    
    // MARK: Instance Variables
    var postController: PostController!
    private var user = User.current()
    private var navBorder: UIView!
    private var applePay: ApplePay!
    private var previousValue: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        self.view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
        
        // Create Apple Pay
        self.applePay = ApplePay(user: self.user)
        self.applePay.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Navigation Bar
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Add Bottom Border To Nav Bar
        if let frame = self.navigationController?.navigationBar.frame {
            self.navBorder = UIView(frame: CGRectMake(0, frame.height-1, frame.width, 1))
            self.navBorder.backgroundColor = UIColor(white: 0, alpha: 0.2)
            self.navigationController?.navigationBar.addSubview(self.navBorder)
        }
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.22, green:0.35, blue:0.41, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Set CheckMark
        if self.postController == nil {
            self.setCheckMark(false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.user.card != nil {
            var isApplePay = self.user.getCardName() == "Apple Pay"
            var applePay = isApplePay && self.user.isApplePayActive()
            var card = !isApplePay && !self.user.card.isEmpty
            
            self.postController?.cardWasAdded = applePay || card
        } else {
            self.postController?.cardWasAdded = false
        }
        
        self.navBorder.removeFromSuperview()
        
        if self.previousValue != self.user.card {
            Global.reloadSettingsController()
        }
    }
    
    // MARK: Instance Methods
    func setCheckMark(trigger: Bool) {
        self.user = User.current()
        
        var cell0 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        var cell1 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        
        cell0?.accessoryType = .None
        cell1?.accessoryType = .None
        
        if self.user.card != nil {
            if self.user.getCardName() == "Apple Pay" && self.applePay.enabled {
                cell1?.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if !self.user.card.isEmpty {
                cell0?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        
        if self.previousValue == nil {
            self.previousValue = self.user.card
        }
        
        if self.postController != nil && trigger {
            self.applePayClose()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: UITableViewController Methods
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 && !self.applePay.enabled {
            return 0
        }
        
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 1 {
            // Apple Pay
            if self.postController == nil {
                if self.user.getCardName() != "Apple Pay" {
                    self.user.changeCard("Apple Pay,0")
                    self.setCheckMark(true)
                }
            } else {
                var modal = self.applePay.getModal(self.postController.subjectChosen.price)
                self.presentViewController(modal, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Payment Methods
    func applePayAuthorized(authorized: Bool) {
        if authorized {
            self.setCheckMark(true)
        }
    }
    
    func applePayClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

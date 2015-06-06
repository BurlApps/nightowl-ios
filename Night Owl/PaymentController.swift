//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/4/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PaymentController: UITableViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    // MARK: Instance Variables
    var postController: PostController!
    private var user = User.current()
    private var navBorder: UIView!
    private var request: PKPaymentRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        self.view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
        
        // Create Payment
        if var request = Stripe.paymentRequestWithMerchantIdentifier("merchant.com.vallelungabrian.Night-Owl") {
            self.request = request
            
            self.request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "With Night Owl", amount: 0.01)
            ]
        }
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
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Set CheckMark
        self.setCheckMark()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

        self.postController?.cardWasAdded = (self.user.card != nil && !self.user.card.isEmpty)
        self.navBorder.removeFromSuperview()
        Global.reloadSettingsController()
    }
    
    // MARK: Instance Methods
    func setCheckMark() {
        self.user = User.current()
        
        var cell0 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        var cell1 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        var cell2 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        
        cell0?.accessoryType = .None
        cell1?.accessoryType = .None
        cell2?.accessoryType = .None
        
        if self.user.card != nil {
            if(self.user.card == "Apple Pay") {
                cell1?.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if(self.user.card == "Venmo") {
                cell2?.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if !self.user.card.isEmpty {
                cell0?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
    }
    
    // MARK: UITableViewController Methods
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 && !Stripe.canSubmitPaymentRequest(self.request) {
            return 0
        }
        
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 1 {
            // Apple Pay
            #if DEBUG
                var paymentController = STPTestPaymentAuthorizationViewController(paymentRequest: self.request)
                paymentController.delegate = self
                self.presentViewController(paymentController, animated: true, completion: nil)
            #else
                var paymentController = PKPaymentAuthorizationViewController(paymentRequest: self.request)
                paymentController.delegate = self
                self.presentViewController(paymentController, animated: true, completion: nil)
            #endif
        } else if indexPath.row == 2 {
            // Venmo
            self.user.addVenmo({ (error) -> Void in
                self.setCheckMark()
            })
        }
    }
    
    // MARK: Payment Methods
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {        
        self.user.addApplePay(payment, callback: { (error) -> Void in
            if error == nil {
                completion(.Success)
            } else {
                completion(.Failure)
            }
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.setCheckMark()
    }
}

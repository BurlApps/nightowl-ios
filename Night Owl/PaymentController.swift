//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PaymentController: UIViewController, CardIOViewDelegate {
    
    // MARK: Instance Variables
    private var user = User.current()
    
    // MARK: IBOutlets
    @IBOutlet weak var cardView: CardIOView!
    @IBOutlet weak var manualButton: UIButton!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Add Create Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 2))
        buttonBorder.backgroundColor = UIColor(white: 1, alpha: 0.2)
        self.manualButton.addSubview(buttonBorder)
        
        // Add CardView Delegate
        if CardIOUtilities.canReadCardWithCamera() {
            self.cardView.delegate = self
        } else {
            self.performSegueWithIdentifier("manualSegue", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CardIOUtilities.preload()
    }
    
    // MARK: CardIOView Methods
    func cardIOView(cardIOView: CardIOView!, didScanCard cardInfo: CardIOCreditCardInfo!) {
        if cardInfo != nil {
            self.user.updateCard(cardInfo, callback: { (error) -> Void in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    UIAlertView(title: "Credit Card Error", message: error.localizedDescription,
                        delegate: self, cancelButtonTitle: "Rescan Card").show()
                }
            })
        }
    }
}

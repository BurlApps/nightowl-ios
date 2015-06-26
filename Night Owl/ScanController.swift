//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class ScanController: UIViewController, CardIOViewDelegate {
    
    // MARK: Instance Variables
    var paymentController: CardController!
    private var user = User.current()
    
    // MARK: IBOutlets
    @IBOutlet weak var cardView: CardIOView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Add CardView Delegate
        if CardIOUtilities.canReadCardWithCamera() {
            self.cardView.delegate = self
        } else {
            self.performSegueWithIdentifier("manualSegue", sender: self)
        }
        
        // Track Event
        self.user.mixpanel.track("MOBILE: Scan Card Page")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CardIOUtilities.preload()
    }
    
    // MARK: CardIOView Methods
    func cardIOView(cardIOView: CardIOView!, didScanCard cardInfo: CardIOCreditCardInfo!) {
        if cardInfo != nil {
            let cardNumber = PTKCardNumber(string: cardInfo.cardNumber)
            let cardExpiration = PTKCardExpiry(string: "\(cardInfo.expiryMonth)/\(cardInfo.expiryYear)")
            var cardExpirationValid = false
            self.paymentController.cardInput.text = cardNumber.formattedString()
            
            if cardExpiration.month != 0 && cardExpiration.year != 0 {
                self.paymentController.expirationInput.text = cardExpiration.formattedString()
                cardExpirationValid = true
            }
            
            self.navigationController?.popViewControllerAnimated(true)
            
            if cardExpirationValid {
                self.paymentController.cvcInput.becomeFirstResponder()
            } else {
                self.paymentController.expirationInput.becomeFirstResponder()
            }
            
        } else {
            UIAlertView(title: "Aww Snap!", message: "We were not able to scan your card :( Please try again.",
                delegate: nil, cancelButtonTitle: "Okay").show()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

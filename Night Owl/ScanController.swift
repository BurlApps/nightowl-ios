//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class ScanController: UIViewController, CardIOViewDelegate {
    
    // MARK: Instance Variables
    var paymentController: PaymentController!
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
            self.paymentController.cardInput.text = cardNumber.formattedString()
            self.paymentController.expirationInput.text = cardExpiration.formattedString()
            self.navigationController?.popViewControllerAnimated(true)
            self.paymentController.cvcInput.becomeFirstResponder()
        } else {
            UIAlertView(title: "Failed to Scan", message: "We were not able to scan your card :(",
                delegate: nil, cancelButtonTitle: "Okay").show()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

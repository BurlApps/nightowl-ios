//
//  ManualEntryController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class CardController: UIViewController {
    
    // MARK: Instance Variables
    var paymentController: PaymentController!
    private var user = User.current()
    
    // MARK: IBoutlets
    @IBOutlet weak var cardInput: UITextField!
    @IBOutlet weak var expirationInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scanButton: UIButton!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        self.view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
        
        // Disable Save Button
        self.saveButton.enabled = false
        
        // Configure Inputs
        self.cardInput.borderStyle = .None
        self.expirationInput.borderStyle = .None
        self.cvcInput.borderStyle = .None
        
        self.cardInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        self.expirationInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        self.cvcInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        
        self.cardInput.leftViewMode = .Always
        self.expirationInput.leftViewMode = .Always
        self.cvcInput.leftViewMode = .Always
        
        self.cardInput.layer.borderWidth = 1
        self.expirationInput.layer.borderWidth = 1
        self.cvcInput.layer.borderWidth = 1
        
        self.cardInput.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1).CGColor
        self.expirationInput.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1).CGColor
        self.cvcInput.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1).CGColor
        
        // Card Input First Responder
        self.cardInput.becomeFirstResponder()
        
        // Add CardView Delegate
        if !CardIOUtilities.canReadCardWithCamera() {
            self.scanButton.hidden = true
        }
        
        // Track Event
        self.user.mixpanel.track("Mobile.Card.Page")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Preload Card Scanner
        CardIOUtilities.preload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! ScanController
        viewController.paymentController = self
    }
    
    // MARK: Update Save Button
    func updateButton() {
        let number = PTKCardNumber(string: self.cardInput.text)
        let expiration = PTKCardExpiry(string: self.expirationInput.text)
        let cvc = PTKCardCVC(string: self.cvcInput.text)
        
        self.saveButton.enabled = number.isValid() && expiration.isValid() && cvc.isValid()
    }
    
    // MARK: IBActions
    @IBAction func cardNumberChanged(sender: UITextField) {
        let number = PTKCardNumber(string: sender.text)
        
        if number.isPartiallyValid() {
            sender.text = number.formattedString()
            sender.textColor = UIColor.blackColor()
            
            if number.isValid() {
                self.expirationInput.becomeFirstResponder()
            }
        } else if !number.isValid() {
            var temp = NSString(string: sender.text)
            sender.text = temp.substringToIndex(temp.length - 1) as String
            sender.textColor = UIColor(red:0.89, green:0.1, blue:0.1, alpha:1)
        }
        
        self.updateButton()
    }
    
    @IBAction func cardExpirationChanged(sender: UITextField) {
        let expiration = PTKCardExpiry(string: sender.text)
        
        if expiration.isPartiallyValid() {
            sender.text = expiration.formattedString()
            sender.textColor = UIColor.blackColor()
            
            if expiration.isValid() {
                self.cvcInput.becomeFirstResponder()
            }
        } else if !expiration.isValid() {
            var temp = NSString(string: sender.text)
            sender.text = temp.substringToIndex(temp.length - 1) as String
            sender.textColor = UIColor(red:0.89, green:0.1, blue:0.1, alpha:1)
        }
        
        self.updateButton()
    }
    
    @IBAction func cardCVCChanged(sender: UITextField) {
        let cvc = PTKCardCVC(string: sender.text)
        
        if cvc.isPartiallyValid() {
            sender.text = cvc.formattedString()
            sender.textColor = UIColor.blackColor()
        } else if !cvc.isValid() {
            var temp = NSString(string: sender.text)
            sender.text = temp.substringToIndex(temp.length - 1) as String
            sender.textColor = UIColor(red:0.89, green:0.1, blue:0.1, alpha:1)
        }
        
        self.updateButton()
    }
    
    @IBAction func saveCard(sender: UIBarButtonItem) {
        var card = CardIOCreditCardInfo()
        let expiration = PTKCardExpiry(string: self.expirationInput.text)
        card.cardNumber = self.cardInput.text
        card.expiryMonth = expiration.month
        card.expiryYear = expiration.year
        card.cvv = self.cvcInput.text
        
        self.saveButton.enabled = false
        
        self.user.updateCard(card, callback: { (error) -> Void in
            if error == nil {
                self.navigationController?.popViewControllerAnimated(true)
                self.paymentController.setCheckMark(true)
                Global.reloadSettingsController()
            } else {
                UIAlertView(title: "Credit Card Error", message: error.localizedDescription,
                    delegate: self, cancelButtonTitle: "Okay").show()
                self.saveButton.enabled = true
            }
        })
    }
}

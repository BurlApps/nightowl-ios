//
//  ManualEntryController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PaymentController: UIViewController {
    
    // MARK: Instance Variables
    var settingsController: SettingsController!
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
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
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
        
        self.cardInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.expirationInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.cvcInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        // Card Input First Responder
        self.cardInput.becomeFirstResponder()
        
        // Add CardView Delegate
        if !CardIOUtilities.canReadCardWithCamera() {
            self.scanButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CardIOUtilities.preload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as ScanController
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
            
            if number.isValid() {
                self.expirationInput.becomeFirstResponder()
            }
        }
        
        self.updateButton()
    }
    
    @IBAction func cardExpirationChanged(sender: UITextField) {
        let expiration = PTKCardExpiry(string: sender.text)
        
        if expiration.isPartiallyValid() {
            sender.text = expiration.formattedString()
            
            if expiration.isValid() {
                self.cvcInput.becomeFirstResponder()
            }
        }
        
        self.updateButton()
    }
    
    @IBAction func cardCVCChanged(sender: UITextField) {
        let cvc = PTKCardCVC(string: sender.text)
        
        if cvc.isPartiallyValid() {
            sender.text = cvc.formattedString()
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
        
        self.user.updateCard(card, callback: { (error) -> Void in
            if error == nil {
                self.settingsController.reloadUser()
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                UIAlertView(title: "Credit Card Error", message: error.localizedDescription,
                    delegate: self, cancelButtonTitle: "Okay").show()
            }
        })
    }
}

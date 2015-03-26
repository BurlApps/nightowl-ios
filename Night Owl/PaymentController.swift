//
//  PaymentController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PaymentController: UIViewController, PTKViewDelegate {
    
    // MARK: Instance Variables
    var settingsController: SettingsController!
    private var card: PTKCard!
    private var valid = false
    private var paymentView: PTKView!
    private var user = User.current()
    
    // MARK: IBOutlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Edge For Layout
        self.edgesForExtendedLayout = UIRectEdge.None;
        
        // Hide Error Label
        self.errorLabel.alpha = 0
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set Payment View Delegate
        let xCol = (self.view.frame.size.width - 290)/2
        self.paymentView = PTKView(frame: CGRectMake(xCol, 100, 290, 55))
        self.paymentView.delegate = self
        self.view.addSubview(self.paymentView)
        
        // Disable Save Button
        self.saveButton.enabled = false
    }
    
    // MARK: IBActions
    @IBAction func saveCard(sender: UIBarButtonItem) {
        self.user.updateCard(self.card) { (error) -> Void in
            if error == nil {
                self.settingsController.reloadUser()
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.alpha = 1
            }
        }
    }
    
    // PTKView Methods
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        self.card = card
        self.valid = valid
        self.saveButton.enabled = valid
    }
}

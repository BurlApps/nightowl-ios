//
//  ApplePay.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/6/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

protocol ApplePayDelegate {
    func applePayAuthorized(authorized: Bool)
    func applePayClose()
}

class ApplePay: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    
    // MARK: Instance Variables
    var enabled: Bool = false
    var delegate: ApplePayDelegate!
    private var user: User!
    private var request: PKPaymentRequest!
    
    // MARK: Convenience Methods
    convenience init(user: User) {
        self.init()
        
        self.user = user
        
        if var request = Stripe.paymentRequestWithMerchantIdentifier("merchant.com.vallelungabrian.Night-Owl") {
            self.request = request
            
            self.request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "With Night Owl", amount: 0.01)
            ]
            
            enabled = Stripe.canSubmitPaymentRequest(self.request)
        }
    }
    
    // MARK: Instance Methods
    func getModal() -> UIViewController! {
        if enabled {
            var paymentController = PKPaymentAuthorizationViewController(paymentRequest: self.request)
            paymentController.delegate = self
            return paymentController
        }
        
        return nil
    }
    
    // MARK: Payment Methods
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        self.user.addApplePay(payment, callback: { (error) -> Void in
            self.delegate.applePayAuthorized(error == nil)
            
            if error == nil {
                completion(.Success)
            } else {
                completion(.Failure)
                println(error)
            }
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        self.delegate.applePayClose()
    }
}
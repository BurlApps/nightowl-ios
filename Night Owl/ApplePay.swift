//
//  ApplePay.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/6/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

@objc protocol ApplePayDelegate {
    optional func applePayAuthorized(authorized: Bool)
    optional func applePayClose()
}

class ApplePay: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    
    // MARK: Instance Variables
    var enabled = false
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
                PKPaymentSummaryItem(label: "Night Owl", amount: 0.99)
            ]
            
            //self.enabled = Stripe.canSubmitPaymentRequest(self.request)
        }
    }
    
    // MARK: Instance Methods
    func getModal(price: Float) -> UIViewController! {
        if enabled {
            self.request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Night Owl", amount: NSDecimalNumber(float: price))
            ]
            
            if var paymentController = PKPaymentAuthorizationViewController(paymentRequest: self.request) {
                paymentController.delegate = self
                
                self.user.mixpanel.track("Mobile.Apple Pay.Page", properties: [
                    "Price": price
                ])
                
                return paymentController
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    // MARK: Payment Methods
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        self.user.addApplePay(payment, callback: { (error) -> Void in
            self.delegate.applePayAuthorized?(error == nil)
            
            if error == nil {
                completion(.Success)
            } else {
                completion(.Failure)
                println(error)
            }
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        self.delegate.applePayClose?()
    }
}

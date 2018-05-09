//
//  OneTapFlowViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
class OneTapFlowViewModel: NSObject {
    enum Steps: String {
        case ACTION_FINISH
        case SCREEN_REVIEW_AND_CONFIRM_ONE_TAP
        case SCREEN_SECURITY_CODE
    }

    var paymentData: PaymentData
    let checkoutPreference: CheckoutPreference
    var paymentOptionSelected: PaymentMethodOption
    let search: PaymentMethodSearch
    var readyToPay: Bool = false
    var payerCosts: [PayerCost]?

    let mpESCManager: MercadoPagoESC = MercadoPagoESCImplementation()
    let reviewScreenPreference = ReviewScreenPreference()
    let mercadoPagoServicesAdapter = MercadoPagoServicesAdapter(servicePreference: MercadoPagoCheckoutViewModel.servicePreference)

    init(paymentData: PaymentData, checkoutPreference: CheckoutPreference, search: PaymentMethodSearch, paymentOptionSelected: PaymentMethodOption) {
        self.paymentData = paymentData.copy() as? PaymentData ?? paymentData
        self.checkoutPreference = checkoutPreference
        self.search = search
        self.paymentOptionSelected = paymentOptionSelected
        super.init()

        updateCheckoutModel(payerCosts: search.defaultInstallments)
    }
    public func nextStep() -> Steps {
        if needReviewAndConfirmForOneTap() {
            return .SCREEN_REVIEW_AND_CONFIRM_ONE_TAP
        }
        if needSecurityCode() {
            return .SCREEN_SECURITY_CODE
        }
        return .ACTION_FINISH
    }
}

// MARK: Create view model
extension OneTapFlowViewModel {
    public func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        guard let cardInformation = self.paymentOptionSelected as? CardInformation else {
            fatalError("Cannot conver payment option selected to CardInformation")
        }

        let reason = SecurityCodeViewModel.Reason.SAVED_CARD
        return SecurityCodeViewModel(paymentMethod: paymentData.paymentMethod!, cardInfo: cardInformation, reason: reason)
    }

    func reviewConfirmViewModel() -> PXReviewViewModel {
        return PXReviewViewModel(checkoutPreference: checkoutPreference, paymentData: paymentData, paymentOptionSelected: paymentOptionSelected, discount: paymentData.discount, reviewScreenPreference: reviewScreenPreference)
    }
}

// MARK: Update view models
extension OneTapFlowViewModel {
    func updateCheckoutModel(paymentData: PaymentData) {
        self.paymentData = paymentData
        self.readyToPay = true
    }

    public func updateCheckoutModel(token: Token) {
        self.paymentData.updatePaymentDataWith(token: token)
    }

    public func updateCheckoutModel(payerCost: PayerCost) {
        self.paymentData.updatePaymentDataWith(payerCost: payerCost)
        self.paymentData.cleanToken()
    }

    public func updateCheckoutModel(payerCosts: [PayerCost]?) {
        guard let payerCosts = payerCosts else {
            return
        }
        // Guarda todas las payerCosts que vengan de backend en one tap. En v1 solamente viene una
        self.payerCosts = payerCosts
        if let first = payerCosts.first, payerCosts.count == 1, paymentOptionSelected.isCard() {
            self.paymentData.updatePaymentDataWith(payerCost: first)
            self.paymentData.cleanToken()
        }
    }

    internal func getAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        } else if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        } else {
            return checkoutPreference.getAmount()
        }
    }
}

// MARK: Flow logic
extension OneTapFlowViewModel {
    func needReviewAndConfirmForOneTap() -> Bool {
        if readyToPay {
            return false
        }

        if paymentData.isComplete(shouldCheckForToken: false) {
            return true
        }

        if paymentData.isComplete(shouldCheckForToken: false) {
            return MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable()
        }
        return false
    }

    func needSecurityCode() -> Bool {
        guard let pm = self.paymentData.getPaymentMethod() else {
            return false
        }

        if !readyToPay {
            return false
        }

        let hasInstallmentsIfNeeded = paymentData.hasPayerCost() || !pm.isCreditCard
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() && paymentOptionSelected.getId() != PaymentTypeId.ACCOUNT_MONEY.rawValue

        if  isCustomerCard && !paymentData.hasToken() && hasInstallmentsIfNeeded && !hasSavedESC() {
            return true
        }
        return false
    }

    func hasSavedESC() -> Bool {
        if let card = paymentOptionSelected as? CardInformation {
            return mpESCManager.getESC(cardId: card.getCardId()) == nil ? false : true
        }
        return false
    }
}

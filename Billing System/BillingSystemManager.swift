//
//  BillingSystemManager.swift
//  Billing System
//
//  Created by Raja Vijaya Kumar on 30/08/23.
//

import Foundation

struct BillingSystemManager {
    private let billableItems: CustomerNamesAndItems
    private let paymentMethod: PaymentMethod
    private let tabCredit: Double
    @PercentageWithinHundred private var taxPercentage: Double
    @PercentageWithinHundred private var discountPercentage: Double
    private let flatDiscount: Double
    @NonZeroPositiveNumber private var splitNum: Int
    
    private var _billDetails: [CustomerDetails: Bill] = [:]
    
    var billDetails: [CustomerDetails: Bill] {
        return _billDetails
    }
    
    private func getPreTaxedItemPrice(item: MenuItem) -> Double {
        return (item.price / (1 + (taxPercentage / 100)))
    }
    
    private func getPreTaxedItemTotalPrice(item: MenuItem) -> Double {
        return getPreTaxedItemPrice(item: item) * Double(item.quantity)
    }
    
    init(billableItems: CustomerNamesAndItems,
         paymentMethod: PaymentMethod,
         tabCredit: Double = 0,
         taxPercentage: Double = 5,
         discountPercentage: Double = 0,
         flatDiscount: Double = 0,
         splitNum: Int = 1
    ) {
        self.billableItems = billableItems
        self.paymentMethod = paymentMethod
        self.tabCredit = tabCredit
        self.taxPercentage = taxPercentage
        self.discountPercentage = discountPercentage
        self.flatDiscount = flatDiscount
        self.splitNum = splitNum
        self.generateBill()
    }
    
    private mutating func generateBill() {
        for (customer, items) in billableItems {
            var totalBill: Double = 0
            var menuItems: [MenuItem] = []
            for item in items {
                let itemPrice = getPreTaxedItemPrice(item: item)
                let totalPrice = getPreTaxedItemTotalPrice(item: item)
                totalBill += totalPrice
                menuItems.append(MenuItem(name: item.name, price: itemPrice, quantity: item.quantity, totalPrice: totalPrice))
            }
            totalBill = max(0, totalBill)
            let pureBillAmount = totalBill
            totalBill += (totalBill * taxPercentage) / 100
            totalBill -= tabCredit
            totalBill -= (totalBill * discountPercentage) / 100
            totalBill -= flatDiscount
            if let surCharges = paymentMethod.applicableSurcharges {
                totalBill += (totalBill * surCharges) / 100
            }
            let finalBill = totalBill
            let finalSplitBill = totalBill / Double(splitNum)
            self._billDetails[customer] = Bill(
                taxPercentage: taxPercentage,
                items: menuItems,
                pureBillAmount: pureBillAmount,
                tabCredit: tabCredit,
                percentDiscount: discountPercentage,
                flatDiscount: flatDiscount,
                surcharges: paymentMethod.applicableSurcharges ?? 0,
                finalBill: finalBill,
                finalSplitBill: finalSplitBill
            )
        }
    }
    
}

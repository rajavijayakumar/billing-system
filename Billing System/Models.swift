//
//  Models.swift
//  Billing System
//
//  Created by Raja Vijaya Kumar on 30/08/23.
//

import Foundation

typealias CustomerNamesAndItems = [CustomerDetails: [MenuItem]]

enum PaymentMethod {
    case cash, upi, creditCard, debitCard
    
    var applicableSurcharges: Double? {
        switch self {
        case .creditCard: return 1.2
        default: return nil
        }
    }
}

struct CustomerDetails: Hashable {
    let name: String
    let contactNo: String
}

struct MenuItem {
    let name: String
    let price: Double
    let quantity: Int
    var totalPrice: Double?
}

struct Bill {
    let taxPercentage: Double
    let items: [MenuItem]
    let pureBillAmount: Double
    let tabCredit: Double
    let percentDiscount: Double
    let flatDiscount: Double
    let surcharges: Double
    let finalBill: Double
    let finalSplitBill: Double
    
    var afterTaxBillAmount: Double {
        let value = (pureBillAmount * taxPercentage) / 100
        return value + pureBillAmount
    }
    
    var afterTabCredit: Double {
        return afterTaxBillAmount - tabCredit;
    }
    
    var afterPecentDiscount: Double {
        return afterTabCredit - (afterTabCredit * Double(percentDiscount)) / 100
    }
    
    var afterFlatDiscount: Double {
        return afterPecentDiscount - flatDiscount
    }
    
    var afterSurcharges: Double {
        return afterFlatDiscount + (afterFlatDiscount * surcharges) / 100
    }
    
    func printBill() {
        let str = "S No".paddedToWidth(6) + "Name".paddedToWidth(22) + "Rate".paddedToWidth(7) + "Quantity".paddedToWidth(10) + "Total Price".paddedToWidth(10)
        var count = 1
        print(str)
        for item in items {
            let str = "\(count)".paddedToWidth(6) + "\(item.name)".paddedToWidth(22) + "$\(item.price.toString())".paddedToWidth(7) + "\(item.quantity)".paddedToWidth(10) + "$\(item.totalPrice?.toString() ?? "")".paddedToWidth(10)
            count += 1
            print(str)
        }
        print("---------------------------------------------------------")
        print("".paddedToWidth(28) + "Gross Total".paddedToWidth(17) + "$\(pureBillAmount.toString())")
        print("\n")
        print("".paddedToWidth(28) + "Total Tax".paddedToWidth(17) + "\(taxPercentage.toString())%")
        print("".paddedToWidth(28) + "".paddedToWidth(17) + "$\(afterTaxBillAmount.toString())")
        print("\n")
        print("".paddedToWidth(28) + "Tab Credit".paddedToWidth(17) + "\(tabCredit.toString())%")
        print("".paddedToWidth(28) + "".paddedToWidth(17) + "$\(afterTabCredit.toString())")
        print("\n")
        print("".paddedToWidth(28) + "Discount %".paddedToWidth(17) + "\(percentDiscount.toString())%")
        print("".paddedToWidth(28) + "".paddedToWidth(17) + "$\(afterPecentDiscount.toString())")
        print("\n")
        print("".paddedToWidth(28) + "Flat".paddedToWidth(17) + "$\(flatDiscount.toString())")
        print("".paddedToWidth(28) + "".paddedToWidth(17) + "$\(afterFlatDiscount.toString())")
        print("\n")
        print("".paddedToWidth(28) + "surcharges".paddedToWidth(17) + "$\(surcharges.toString())")
        print("".paddedToWidth(28) + "".paddedToWidth(17) + "$\(afterSurcharges.toString())")
        print("\n")
        print("".paddedToWidth(28) + "Final Bill".paddedToWidth(17) + "\(finalBill.toString())%")
        if (finalBill != finalSplitBill) {
            print("".paddedToWidth(28) + "Bill Shared".paddedToWidth(17) + "\((finalBill / finalSplitBill).toString())")
            print("".paddedToWidth(28) + "Final Split Bill".paddedToWidth(17) + "$\(finalSplitBill.toString())")
        }
    }
}

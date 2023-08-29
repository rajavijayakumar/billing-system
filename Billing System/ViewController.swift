//
//  ViewController.swift
//  Billing System
//
//  Created by Raja Vijaya Kumar on 29/08/23.
//

import UIKit

public extension String {
    func paddedToWidth(_ width: Int) -> String {
        let length = self.count
        guard length < width else {
            return self
        }

        let spaces = Array<Character>.init(repeating: " ", count: width - length)
        return self + spaces
    }
}

extension Double {
    func toString(decimalPlaces: Int = 2) -> String {
        return String(format: "%.2f", self)
    }
}

@propertyWrapper struct NonZeroPositiveNumber {
    var wrappedValue: Int {
        didSet {
            wrappedValue = wrappedValue <= 0 ? 1 : wrappedValue
        }
    }
}

@propertyWrapper struct PercentageWithinHundred {
    var wrappedValue: Double {
        didSet {
            wrappedValue = max(0, wrappedValue)
            wrappedValue = min(wrappedValue, 100)
        }
    }
}

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

typealias CustomerNamesAndItems = [CustomerDetails: [MenuItem]]

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

class ViewController: UIViewController {
    
    func printBill(_ val: [CustomerDetails: Bill]) {
        for (customer, bill) in val {
            print("Customer Name: ", customer.name)
            print("Contact: ", customer.contactNo)
            print("Bill Details")
            bill.printBill()
        }
        print("\n")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scenario 1
        let personOneItems: [MenuItem] = [
            MenuItem(name: "Big Brekkie", price: 16, quantity: 1),
            MenuItem(name: "Tea", price: 3, quantity: 1),
        ]
        
        let personTwoItems: [MenuItem] = [
            MenuItem(name: "Big Brekkie", price: 16, quantity: 1),
            MenuItem(name: "Coffee", price: 5, quantity: 1),
        ]
        
        let personThreeItems: [MenuItem] = [
            MenuItem(name: "Poached Eggs", price: 12, quantity: 1),
            MenuItem(name: "Bruchetta", price: 8, quantity: 1),
            MenuItem(name: "Soda", price: 4, quantity: 1),
        ]
        
        let personOneDetail = CustomerDetails(name: "James", contactNo: "+1 232 341 0987")
        let personTwoDetail = CustomerDetails(name: "Michael", contactNo: "+1 238 345 1445")
        let personThreeDetail = CustomerDetails(name: "Brenda", contactNo: "+1 255 112 8880")
        
        let bill1 = BillingSystemManager(billableItems: [personOneDetail: personOneItems, personTwoDetail: personTwoItems, personThreeDetail: personThreeItems], paymentMethod: .cash)
        printBill(bill1.billDetails)
        
        // Scenario 2
        let menuItems2: [MenuItem] = [
            MenuItem(name: "Tea", price: 3, quantity: 1),
            MenuItem(name: "Coffee", price: 3, quantity: 3),
            MenuItem(name: "Soda", price: 4, quantity: 1),
            MenuItem(name: "Big Brekkie", price: 16, quantity: 3),
            MenuItem(name: "Poached Eggs", price: 12, quantity: 1),
            MenuItem(name: "Garden Salad", price: 10, quantity: 1)
        ]
        
        let customerDetail2 = CustomerDetails(name: "Barry Alen", contactNo: "+1 332 965 7944")
        
        let bill2 = BillingSystemManager(billableItems: [customerDetail2: menuItems2], paymentMethod: .creditCard, discountPercentage: 10)
        printBill(bill2.billDetails)
        
        // Scenario 3
        let menuItems3: [MenuItem] = [
            MenuItem(name: "Tea", price: 3, quantity: 2),
            MenuItem(name: "Coffee", price: 3, quantity: 3),
            MenuItem(name: "Soda", price: 4, quantity: 2),
            MenuItem(name: "Bruchetta", price: 8, quantity: 5),
            MenuItem(name: "Big Brekkie", price: 16, quantity: 5),
            MenuItem(name: "Poached Eggs", price: 12, quantity: 2),
            MenuItem(name: "Garden Salad", price: 10, quantity: 3)
        ]
        
        let customerDetail3 = CustomerDetails(name: "Jordan Belfort", contactNo: "+1 445 709 4400")
        
        
        let bill3 = BillingSystemManager(billableItems: [customerDetail3: menuItems3], paymentMethod: .upi, tabCredit: 50, taxPercentage: 5, flatDiscount: 25, splitNum: 7)
        printBill(bill3.billDetails)
    }


}


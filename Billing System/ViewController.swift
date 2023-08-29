//
//  ViewController.swift
//  Billing System
//
//  Created by Raja Vijaya Kumar on 29/08/23.
//

import UIKit

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


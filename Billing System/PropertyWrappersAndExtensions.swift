//
//  PropertyWrappersAndExtensions.swift
//  Billing System
//
//  Created by Raja Vijaya Kumar on 30/08/23.
//

import Foundation

extension String {
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

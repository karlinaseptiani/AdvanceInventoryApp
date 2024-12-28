//
//  Transaction.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 26/12/24.
//


import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var itemId: String
    var itemName: String
    var type: String
    var quantity: Int
    var date: Date
    var supplierID: String

    init(id: String? = nil, itemId: String, itemName: String, type: String, quantity: Int, date: Date, supplierID: String) {
        self.id = id
        self.itemId = itemId
        self.itemName = itemName
        self.type = type
        self.quantity = quantity
        self.date = date
        self.supplierID = supplierID
    }
}
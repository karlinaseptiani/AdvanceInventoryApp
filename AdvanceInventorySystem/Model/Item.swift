//
//  Item.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 26/12/24.
//


import Foundation
import FirebaseFirestore

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var category: String
    var price: Double
    var stock: Int
    var imageURL: String?
    var supplierID: String
    var supplierName: String
    var userID: String

    init(id: String? = nil, name: String, description: String, category: String, price: Double, stock: Int, imageURL: String? = nil, supplierID: String, supplierName: String, userID: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.price = price
        self.stock = stock
        self.imageURL = imageURL
        self.supplierID = supplierID
        self.supplierName = supplierName
        self.userID = userID
    }
}
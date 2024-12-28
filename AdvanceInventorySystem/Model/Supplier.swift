//
//  Supplier.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 19/12/24.
//


import Foundation
import FirebaseFirestore

struct Supplier: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userID: String
    var name: String
    var address: String
    var contact: String
    var longitude: Double
    var latitude: Double
    
    // Custom initializer
    init(id: String, userID: String, name: String, address: String, contact: String, longitude: Double, latitude: Double) {
        self.id = id
        self.userID = userID
        self.name = name
        self.address = address
        self.contact = contact
        self.longitude = longitude
        self.latitude = latitude
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case name
        case address
        case contact
        case longitude
        case latitude
    }
}

//
//  Product.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import SwiftUI
import Foundation

struct Product: Identifiable {
    var id: Int
    var name: String
    var description: String
    var category: String
    var price: Double
    var stock: Int
    var imagePath: String
    
}





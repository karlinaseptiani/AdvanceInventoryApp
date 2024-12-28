//
//  User.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 23/12/24.
//


import Foundation
struct Account: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension Account {
    static var SAMPLE_USER = Account(id: NSUUID().uuidString, fullname: "Tobari", email: "tobari@gmail.com")
}

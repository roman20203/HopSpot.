//
//  Manager.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//

import Foundation
import FirebaseFirestoreSwift

class Manager: Identifiable, Codable {
    var id: String // Unique ID for the manager
    var email: String
    var password: String
    var name: String
    var businessIds: [String] // IDs of businesses the manager has access to
    var activeBusiness: Business? //business currently active for this manager

    // Hash the password (implement a more secure hashing algorithm in a real app)
    static func hashPassword(_ password: String) -> String {
        return String(password.reversed()) // Replace with a secure hash function
    }

    init(id: String, email: String, password: String, name: String, businessIds: [String]) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.businessIds = businessIds
        self.activeBusiness = nil
    }

    // Method to change the active business which will then change the apps view
    
    /*
    func changeActiveBusiness(to activeBusiness: Business) {
        self.activeBusiness = activeBusiness
    }
     */
     
}


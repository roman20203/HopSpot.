//
//  Fraternity.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Fraternity: Identifiable, Codable {
    let id: String
    var name: String
    var school: String
    var address: String
    var description: String
    
    //make events optional because there may be nil events
    var events: [Event]?
    
    // Initializer
    init(id: String, name: String, school: String, address: String, description: String, events:[Event]? = nil) {
        self.id = id
        self.name = name
        self.school = school
        self.address = address
        self.description = description
        self.events = events
    }
    
    struct LineReport: Identifiable, Codable {
        var id: String
        var lineLengthOption: String // Updated field name
        var timestamp: Date
    }
}

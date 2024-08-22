//
//  Business.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Business: Identifiable, Codable {
    var id: String
    var name: String
    var club_id: String
    var associatedclubs: [String] 
    
    // Initialize Business
    init(id: String , name: String, club_id: String, associatedclubs: [String]) {
        self.id = id
        self.name = name
        self.club_id = club_id
        self.associatedclubs = associatedclubs
    }

}

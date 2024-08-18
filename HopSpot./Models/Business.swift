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
    var id: String? // ID for Firestore businesses collection = businessId
    var name: String
    var clubId: String // ID for Firestore clubs collection
    var associatedClubs: [String]? // Array of associated businessIds
    
    // Initialize Business
    init(id: String? = nil, name: String, clubId: String, associatedClubs: [String]? = nil) {
        self.id = id
        self.name = name
        self.clubId = clubId
        self.associatedClubs = associatedClubs
    }
    
    // Fetch Club data
    func fetchClub(completion: @escaping (Result<Club, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Clubs").document(clubId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Club document not found"])))
                return
            }
            
            do {
                let club = try Firestore.Decoder().decode(Club.self, from: data)
                completion(.success(club))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// Define a result type to encapsulate the combined data
struct BusinessWithClub {
    var business: Business
    var club: Club
}

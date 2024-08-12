//
//  club_firebase_handler.swift
//  HopSpot.
//
//This will read all the club data from firebase and will initialize club.swift structs for each and store them in a list or something
//
//  Created by Ben Roman on 2024-07-22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class club_firebase_handler: ObservableObject {
    @Published var clubs = [Club]()
    
    private var db = Firestore.firestore()
    
    init() {
        fetchClubs()
    }
    
    func fetchClubs() {
        db.collection("Clubs").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching clubs: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            DispatchQueue.main.async {
                self?.clubs = documents.compactMap { doc -> Club? in
                    let data = doc.data()

                    print("Document data: \(data)")

                    guard let id = data["id"] as? String,
                          let name = data["name"] as? String,
                          let address = data["address"] as? String,
                          let rating = data["rating"] as? Double,
                          let reviewCount = data["reviewCount"] as? Int,
                          let description = data["description"] as? String,
                          let imageURL = data["imageURL"] as? String,
                          let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double,
                          let busyness = data["busyness"] as? Int,
                          let website = data["website"] as? String,
                          let city = data["city"] as? String else {
                        print("Error decoding document data for Club: \(data)")
                        return nil
                    }
                    
                    return Club(id: id, name: name, address: address, rating: rating, reviewCount: reviewCount, description: description, imageURL: imageURL, latitude: latitude, longitude: longitude, busyness: busyness, website: website, city: city)
                }
                    
                // Debugging: Print all clubs
                print("Fetched \(self?.clubs.count ?? 0) clubs")
                self?.clubs.forEach { club in
                    print("Club: \(club.name), Rating: \(club.rating), Website: \(club.website), City: \(club.city)")
                }
            }
        }
    }
    
    func displayPopularClubs(userLocation: CLLocation, distanceThreshold: CLLocationDistance) -> [Club] {
        return clubs.filter { club in
            let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
            let distance = clubLocation.distance(from: userLocation)
            print("Club \(club.name) is \(distance) meters away") // Debugging
            return distance <= distanceThreshold && (club.busyness == .VeryBusy || club.busyness == .Busy)
        }
    }
    
    func displayNearYouClubs(userLocation: CLLocation, distanceThreshold: CLLocationDistance) -> [Club] {
        return clubs.filter { club in
            let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
            let distance = clubLocation.distance(from: userLocation)
            print("Club \(club.name) is \(distance) meters away") // Debugging
            return distance <= distanceThreshold
        }
    }
}

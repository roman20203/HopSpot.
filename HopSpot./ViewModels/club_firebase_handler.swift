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
    @Published var currentPromotions = [Promotion]()
    @Published var upcomingPromotions = [Promotion]()
    
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
            
            let dispatchGroup = DispatchGroup()
            var fetchedClubs = [Club]()
            var fetchedCurrentPromotions = [Promotion]()
            var fetchedUpcomingPromotions = [Promotion]()
            
            for doc in documents {
                let data = doc.data()
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
                    continue
                }
                
                var club = Club(id: id, name: name, address: address, rating: rating, reviewCount: reviewCount, description: description, imageURL: imageURL, latitude: latitude, longitude: longitude, busyness: busyness, website: website, city: city, promotions: [])
                
                dispatchGroup.enter()
                let promotionsRef = self?.db.collection("Clubs").document(id).collection("Promotions")
                promotionsRef?.getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching promotions: \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let promotionDocuments = snapshot?.documents else {
                        print("No promotions found for club: \(club.name)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    let currentDate = Date()
                    club.promotions = promotionDocuments.compactMap { promotionDoc -> Promotion? in
                        if promotionDoc.documentID == "initial" {
                            return nil
                        }
                        
                        let promotionData = promotionDoc.data()
                        let promotion = Promotion(id: promotionDoc.documentID,
                                                  title: promotionData["title"] as? String ?? "",
                                                  description: promotionData["description"] as? String ?? "",
                                                  startDate: (promotionData["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                                                  endDate: (promotionData["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                                                  startTime: (promotionData["startTime"] as? Timestamp)?.dateValue() ?? Date(),
                                                  endTime: (promotionData["endTime"] as? Timestamp)?.dateValue() ?? Date(),
                                                  clubName: promotionData["clubName"] as? String ?? "",
                                                  clubImageURL: promotionData["clubImageURL"] as? String ?? "")
                        
                        // Check if the promotion is either current or upcoming
                        if (promotion.startDate <= currentDate && promotion.endDate >= currentDate) || promotion.startDate > currentDate {
                            if Calendar.current.isDateInToday(promotion.startDate) || (promotion.startDate <= currentDate && promotion.endDate >= currentDate) {
                                fetchedCurrentPromotions.append(promotion)
                            } else if promotion.startDate > currentDate {
                                fetchedUpcomingPromotions.append(promotion)
                            }
                            return promotion
                        }
                        
                        return nil
                    }
                    
                    fetchedClubs.append(club)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self?.clubs = fetchedClubs
                self?.currentPromotions = fetchedCurrentPromotions
                self?.upcomingPromotions = fetchedUpcomingPromotions
                print("Fetched \(self?.clubs.count ?? 0) clubs")
                self?.clubs.forEach { club in
                    print("Club: \(club.name), Rating: \(club.rating), Website: \(club.website), City: \(club.city), Promotions: \(club.promotions.count)")
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
    
    func submitRating(for club: Club, newRating: Int, userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let clubRef = db.collection("Clubs").document(club.id)
        let starReviewsRef = clubRef.collection("StarReviews")
        

        starReviewsRef.whereField("userId", isEqualTo: userId)
        .getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking reviews: \(error)")
                completion(false)
                return
            }
          
            let todayStart = Calendar.current.startOfDay(for: Date())
            let reviewsToday = snapshot?.documents.filter {
                let timestamp = $0.data()["timestamp"] as? Timestamp ?? Timestamp(date: Date.distantPast)
                return timestamp.dateValue() >= todayStart
            } ?? []
            
            if !reviewsToday.isEmpty {
                // User has already reviewed this club today
                print("User has already reviewed this club today.")
                completion(false)
                return
            }
            
            starReviewsRef.addDocument(data: [
                "userId": userId,
                "rating": newRating,
                "timestamp": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("Error submitting review: \(error)")
                    completion(false)
                    return
                }
                
                // Update the club's average rating
                self?.updateClubRating(clubRef: clubRef, newRating: newRating)
                completion(true)
            }
        }
    }

    

    func updateClubRating(clubRef: DocumentReference, newRating: Int) {
       // let starReviewsRef = clubRef.collection("StarReviews")

        // Firestore transaction to safely increment review count and update rating
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let clubDocument: DocumentSnapshot
            do {
                // Attempt to fetch the club document
                clubDocument = try transaction.getDocument(clubRef)
            } catch let fetchError as NSError {
                print("Error fetching club document: \(fetchError.localizedDescription)")
                errorPointer?.pointee = fetchError
                return nil
            }

            // Fetch the current review count and rating
            let currentReviewCount = clubDocument.data()?["reviewCount"] as? Int ?? 0
            let currentRating = clubDocument.data()?["rating"] as? Double ?? 0.0

            // Increment the review count
            let newReviewCount = currentReviewCount + 1

            // Calculate the new average rating
            let totalRatings = (currentRating * Double(currentReviewCount)) + Double(newRating)
            let averageRating = newReviewCount == 0 ? 0.0 : totalRatings / Double(newReviewCount)

            // Update the club document with new values
            transaction.updateData([
                "rating": averageRating,
                "reviewCount": newReviewCount
            ], forDocument: clubRef)

            return nil
        }) { (result, error) in
            if let error = error {
                print("Error updating rating and review count: \(error)")
                return
            }

            print("Successfully updated club rating and review count")
        }
    }



}


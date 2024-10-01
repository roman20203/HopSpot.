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
import MapKit
import SwiftUI

class club_firebase_handler: ObservableObject {
    //@Published var clubs = [Club]()
    @Published var clubs: [Club] = [] {
            didSet {
                print("clubs changed: \(clubs.count) clubs now")
            }
        }
    @Published var currentPromotions = [Promotion]()
    @Published var upcomingPromotions = [Promotion]()
    
    @Published var currentEvents = [Event]()
    @Published var upcomingEvents = [Event]()
    
    @Published var currentFratEvents = [Event]()
    @Published var upcomingFratEvents = [Event]()
    
    @Published var isInitialized = false // Track if data is fetched

    // Locations related properties
    @Published var locations: [Location] = []
    @Published var MapLocation: Club
    @Published var MapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    @Published var showLocationsList: Bool = false
    @Published var sheetLocation: Club? = nil

    private var db = Firestore.firestore()
    
    // Initialization
    init() {
        // Initialize mapLocation with a default location
        self.MapLocation = Club(id: "0000", name: "default", address: "unknown", rating: 0, reviewCount: 0, description: "unkown", imageURL: "unknown", latitude: 43.468911911447954, longitude: -80.52377773702925 , busyness: 40, website: "unknown", city: "Waterloo, ON")
        
        // Call fetchClubs and fetchFratEvents
        self.fetchClubs()
        self.fetchFratEvents()
    }
    
    func fetchFratEvents() {
        db.collection("Waterloo_Frats").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching Frats: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No Frats found")
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var fetchedCurrentFratEvents = [Event]()
            var fetchedUpcomingFratEvents = [Event]()
            
            for doc in documents {
                let id = doc.documentID
                let eventsRef = self.db.collection("Waterloo_Frats").document(id).collection("Events")
                
                dispatchGroup.enter()
                eventsRef.getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching events for frat \(id): \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let eventDocuments = snapshot?.documents else {
                        print("No events found for frat \(id)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    let currentDate = Date()
                    _ = eventDocuments.compactMap { eventDoc -> Event? in
                        if eventDoc.documentID == "initial" {
                            return nil
                        }
                        
                        let eventData = eventDoc.data()
                        let event = Event(id: eventDoc.documentID,
                                          title: eventData["title"] as? String ?? "",
                                          description: eventData["description"] as? String ?? "",
                                          startDate: (eventData["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                                          endDate: (eventData["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                                          startTime: (eventData["startTime"] as? Timestamp)?.dateValue() ?? Date(),
                                          endTime: (eventData["endTime"] as? Timestamp)?.dateValue() ?? Date(),
                                          location: eventData["location"] as? String ?? "",
                                          clubName: eventData["clubName"] as? String ?? "",
                                          clubImageURL: eventData["clubImageURL"] as? String ?? "")
                        
                        // Categorize events
                        let eventStartDate = event.startDate.startOfDay()
                        let eventEndDate = event.endDate.startOfDay()
                        
                        if (eventStartDate <= eventEndDate){
                            if eventStartDate <= currentDate && eventEndDate >= currentDate {
                                
                                fetchedCurrentFratEvents.append(event)
                            }
                        
                            else if eventStartDate > currentDate {
                                fetchedUpcomingFratEvents.append(event)
                            }
                        }
                        return nil
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.currentFratEvents = fetchedCurrentFratEvents.sorted(by: { $0.startDate < $1.startDate })
                self.upcomingFratEvents = fetchedUpcomingFratEvents.sorted(by: { $0.startDate < $1.startDate })
                print("Fetched \(self.currentFratEvents.count) current frat events")
                print("Current: \(self.currentFratEvents)")
                print("Fetched \(self.upcomingFratEvents.count) upcoming frat events")
            }
        }
    }

    
    
    
    func fetchClubs() {
        db.collection("Clubs").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
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
            var fetchedCurrentEvents = [Event]()
            var fetchedUpcomingEvents = [Event]()
            
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
                
                //var club = Club(id: id, name: name, address: address, rating: rating, reviewCount: reviewCount, description: description, imageURL: imageURL, latitude: latitude, longitude: longitude, busyness: busyness, website: website, city: city, promotions: [])
                var club = Club(id: id, name: name, address: address, rating: rating, reviewCount: reviewCount, description: description, imageURL: imageURL, latitude: latitude, longitude: longitude, busyness: busyness, website: website, city: city, promotions: [])
                
                dispatchGroup.enter()
                
                let promotionsRef = self.db.collection("Clubs").document(id).collection("Promotions")
                promotionsRef.getDocuments { snapshot, error in
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
                    
                    let currentDate = Date().startOfDay()
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
                        
                        let promotionStartDate = promotion.startDate.startOfDay()
                        let promotionEndDate = promotion.endDate.startOfDay()
                        
                        if (promotionStartDate <= promotionEndDate){
                            if promotionStartDate <= currentDate && promotionEndDate >= currentDate {
                                // Add to current promotions
                                fetchedCurrentPromotions.append(promotion)
                            }
                            // Check for upcoming promotions (starting in the future)
                            else if promotionStartDate > currentDate {
                                // Add to upcoming promotions
                                fetchedUpcomingPromotions.append(promotion)
                            }
                        }
                        return nil
                    }
                    
                    // Fetch Events for the current club
                    let eventsRef = self.db.collection("Clubs").document(id).collection("Events")
                    eventsRef.getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching events: \(error)")
                            dispatchGroup.leave()
                            return
                        }
                        
                        guard let eventDocuments = snapshot?.documents else {
                            print("No events found for club: \(club.name)")
                            dispatchGroup.leave()
                            return
                        }
                        
                        club.events = eventDocuments.compactMap { eventDoc -> Event? in
                            if eventDoc.documentID == "initial" {
                                return nil
                            }
                            let eventData = eventDoc.data()
                            let event = Event(id: eventDoc.documentID,
                                              title: eventData["title"] as? String ?? "",
                                              description: eventData["description"] as? String ?? "",
                                              startDate: (eventData["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                                              endDate: (eventData["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                                              startTime: (eventData["startTime"] as? Timestamp)?.dateValue() ?? Date(),
                                              endTime: (eventData["endTime"] as? Timestamp)?.dateValue() ?? Date(),
                                              location: eventData["location"] as? String ?? "",
                                              clubName: eventData["clubName"] as? String ?? "",
                                              clubImageURL: eventData["clubImageURL"] as? String ?? "")
                            
                            let eventStartDate = event.startDate.startOfDay()
                            let eventEndDate = event.endDate.startOfDay()
                            
                            if (eventStartDate <= eventEndDate){
                                if eventStartDate <= currentDate && eventEndDate >= currentDate {
                                    // Add to current promotions
                                    fetchedCurrentEvents.append(event)
                                }
                                // Check for upcoming promotions (starting in the future)
                                else if eventStartDate > currentDate {
                                    // Add to upcoming promotions
                                    fetchedUpcomingEvents.append(event)
                                }
                            }
                            
                            return event
                        }
                        fetchedClubs.append(club)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Ensure all updates to @Published properties happen on the main thread
                DispatchQueue.main.async {
                    self.clubs = fetchedClubs
                    // Sort the current promotions and events by startDate
                    self.currentPromotions = fetchedCurrentPromotions.sorted(by: { $0.startDate < $1.startDate })
                    self.upcomingPromotions = fetchedUpcomingPromotions.sorted(by: { $0.startDate < $1.startDate })
                    self.currentEvents = fetchedCurrentEvents.sorted(by: { $0.startDate < $1.startDate })
                    self.upcomingEvents = fetchedUpcomingEvents.sorted(by: { $0.startDate < $1.startDate })

                    
                    self.isInitialized = true
                    print("Fetched \(self.clubs.count) clubs")
                    self.clubs.forEach { club in
                        print("Club: \(club.name), Rating: \(club.rating), Website: \(club.website), City: \(club.city), Promotions: \(club.promotions.count), Events: \(club.events.count)")
                    }
                    //self.updateLocation()
                }
            }
        }
    }
    
    
    func updateMapLocation(location: Club){
        self.MapLocation = location
    }
    
    func updateLocation() {
        guard !clubs.isEmpty else {
                print("Warning: clubs array is empty. Cannot update locations.")
                return
            }
        
        if let firstLocation = clubs.first {
            MapLocation = firstLocation
        } else {
            MapLocation = Club(id: "0000", name: "default", address: "unknown", rating: 0, reviewCount: 0, description: "unkown", imageURL: "unknown", latitude: 43.468911911447954, longitude: -80.52377773702925, busyness: 40, website: "unknown", city: "Waterloo")
            print("Warning: Locations array is empty, using default MapLocation.")
        }
        
        self.updateMapRegion(location: MapLocation)
    }
    
    func updateMapRegion(location: Club) {
        withAnimation(.easeInOut) {
            MapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                span: mapSpan
            )
        }
    }
    
    public func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList
        }
    }
    
    func showNextLocation(location: Club) {
        self.updateMapLocation(location: location)
        self.updateMapRegion(location: location)
        withAnimation(.easeInOut) {
            showLocationsList = false
        }
    }
    
    func nextButtonPressed() {
        guard let currentIndex = clubs.firstIndex(where: { $0 == MapLocation }) else {
            print("Could not find current index in locations array! Should never happen")
            return
        }
        
        let nextIndex = currentIndex + 1
        guard clubs.indices.contains(nextIndex) else {
            guard let firstLocation = clubs.first else {
                return
            }
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = clubs[nextIndex]
        showNextLocation(location: nextLocation)
    }
    
    /*
    func displayPopularClubs(userLocation: CLLocation, distanceThreshold: CLLocationDistance) -> [Club] {
        return clubs.filter { club in
            let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
            let distance = clubLocation.distance(from: userLocation)
            print("Club \(club.name) is \(distance) meters away") // Debugging
            return distance <= distanceThreshold && (club.busyness == .VeryBusy || club.busyness == .Busy)
        }
    }
    */
    func displayPopularClubs(userLocation: CLLocation, distanceThreshold: CLLocationDistance) -> [Club] {
        let currentDate = Date()
        
        return clubs.filter { club in
            let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
            let distance = clubLocation.distance(from: userLocation)
            print("Club \(club.name) is \(distance) meters away") // Debugging
            
            // Check if the club has an active event or promotion
            let hasActiveEvent = club.events.contains { event in
                return event.startDate <= currentDate && event.endDate >= currentDate
            }
            
            let hasActivePromotion = club.promotions.contains { promotion in
                return promotion.startDate <= currentDate && promotion.endDate >= currentDate
            }
            
            return distance <= distanceThreshold && (hasActiveEvent || hasActivePromotion)
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
        
        starReviewsRef.whereField("userId", isEqualTo: userId).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking existing rating: \(error)")
                completion(false)
                return
            }
            
            if let existingReview = snapshot?.documents.first {
                existingReview.reference.updateData([
                    "rating": newRating
                ]) { error in
                    if let error = error {
                        print("Error updating rating: \(error)")
                        completion(false)
                        return
                    }
                    
                    self?.updateClubRating(club: club, newRating: newRating, completion: completion)
                }
            } else {
                starReviewsRef.addDocument(data: [
                    "userId": userId,
                    "rating": newRating
                ]) { [weak self] error in
                    if let error = error {
                        print("Error adding rating: \(error)")
                        completion(false)
                        return
                    }
                    
                    self?.updateClubRating(club: club, newRating: newRating, completion: completion)
                }
            }
        }
    }
    
    private func updateClubRating(club: Club, newRating: Int, completion: @escaping (Bool) -> Void) {
        let clubRef = Firestore.firestore().collection("Clubs").document(club.id)
        
        clubRef.collection("StarReviews").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching star reviews: \(error)")
                completion(false)
                return
            }
            
            let reviews = snapshot?.documents ?? []
            let totalRating = reviews.reduce(0) { $0 + ($1.data()["rating"] as? Int ?? 0) }
            let reviewCount = reviews.count
            
            clubRef.updateData([
                "rating": reviewCount > 0 ? Double(totalRating) / Double(reviewCount) : 0.0,
                "reviewCount": reviewCount
            ]) { error in
                if let error = error {
                    print("Error updating club rating: \(error)")
                    completion(false)
                    return
                }
                
                if let index = self?.clubs.firstIndex(where: { $0.id == club.id }) {
                    self?.clubs[index].rating = Double(totalRating) / Double(reviewCount)
                    self?.clubs[index].reviewCount = reviewCount
                }
                
                completion(true)
            }
            
        }
        
    }
    
    func refresh() {
        fetchClubs()
        fetchFratEvents()
    }
    func refreshFrats(){
        fetchFratEvents()
        print(currentFratEvents)
    }
    func refreshClubs(){
        fetchClubs()
    }
    
    
}
extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}


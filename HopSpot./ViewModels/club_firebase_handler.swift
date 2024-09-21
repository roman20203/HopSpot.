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
    @Published var clubs = [Club]()
    @Published var currentPromotions = [Promotion]()
    @Published var upcomingPromotions = [Promotion]()
    
    @Published var currentEvents = [Event]()
    @Published var upcomingEvents = [Event]()
    
    @Published var currentFratEvents = [Event]()
    @Published var upcomingFratEvents = [Event]()
    
    @Published var isInitialized = false // Track if data is fetched

    // Locations related properties
    @Published var locations: [Location] = []
    @Published var MapLocation: Location
    @Published var MapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @Published var showLocationsList: Bool = false
    @Published var sheetLocation: Location? = nil

    private var db = Firestore.firestore()
    
    // Initialization
    init() {
        // Initialize mapLocation with a default location
        self.MapLocation = Location(
            name: "Default Location",
            cityName: "Unknown",
            coordinates: CLLocationCoordinate2D(latitude: 43.4738, longitude: 80.5275),
            description: "",
            imageNames: "",
            link: ""
        )
        
        // Call fetchClubs after initialization
        DispatchQueue.main.async {
            self.fetchClubs()
            self.fetchFratEvents()
        }
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
                        if (event.startDate <= currentDate && event.endDate >= currentDate) || event.startDate > currentDate {
                            if Calendar.current.isDateInToday(event.startDate) || (event.startDate <= currentDate && event.endDate >= currentDate) {
                                if Calendar.current.isDateInToday(event.startDate) {
                                    fetchedCurrentFratEvents.append(event)
                                } else {
                                    fetchedUpcomingFratEvents.append(event)
                                }
                                return event
                            }
                        }
                        return nil
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.currentFratEvents = fetchedCurrentFratEvents
                self.upcomingFratEvents = fetchedUpcomingFratEvents
                print("Fetched \(self.currentFratEvents.count) current frat events")
                print("Fetched \(self.upcomingFratEvents.count) upcoming frat events")
            }
        }
    }


    
    
    func fetchClubs() {
        db.collection("Clubs").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return}
            
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
                        
                        if (promotion.startDate <= currentDate && promotion.endDate >= currentDate) || promotion.startDate > currentDate {
                            if Calendar.current.isDateInToday(promotion.startDate) || (promotion.startDate <= currentDate && promotion.endDate >= currentDate) {
                                if Calendar.current.isDateInToday(promotion.startDate) {
                                    fetchedCurrentPromotions.append(promotion)
                                } else {
                                    fetchedUpcomingPromotions.append(promotion)
                                    
                                }
                                return promotion
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
                            
                            // Categorize events
                            if event.startDate <= currentDate && event.endDate >= currentDate {
                                fetchedCurrentEvents.append(event)
                            } else if event.startDate > currentDate {
                                fetchedUpcomingEvents.append(event)
                            }
                            
                            return event
                        }
                        fetchedClubs.append(club)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.clubs = fetchedClubs
                self.currentPromotions = fetchedCurrentPromotions
                self.upcomingPromotions = fetchedUpcomingPromotions
                self.currentEvents = fetchedCurrentEvents
                self.upcomingEvents = fetchedUpcomingEvents
                
                self.isInitialized = true
                print("Fetched \(self.clubs.count) clubs")
                self.clubs.forEach { club in
                    print("Club: \(club.name), Rating: \(club.rating), Website: \(club.website), City: \(club.city), Promotions: \(club.promotions.count), Events: \(club.events.count)")
                }
                self.updateLocations()
            }
        }
    }
    
    func updateLocations() {
        locations = clubs.map { club in
            Location(
                name: club.name,
                cityName: club.city,
                coordinates: CLLocationCoordinate2D(latitude: club.latitude, longitude: club.longitude),
                description: club.description,
                imageNames: club.imageURL,
                link: club.website
            )
        }
        
        if let firstLocation = locations.first {
            MapLocation = firstLocation
        } else {
            MapLocation = Location(
                name: "Default Location",
                cityName: "Unknown",
                coordinates: CLLocationCoordinate2D(latitude: 43.4738, longitude: 80.5275),
                description: "",
                imageNames: "",
                link: ""
            )
            print("Warning: Locations array is empty, using default MapLocation.")
        }
        
        updateMapRegion(location: MapLocation)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            MapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan
            )
        }
    }
    
    public func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList
        }
    }
    
    func showNextLocation(location: Location) {
        MapLocation = location
        withAnimation(.easeInOut) {
            showLocationsList = false
        }
    }
    
    func nextButtonPressed() {
        guard let currentIndex = locations.firstIndex(where: { $0 == MapLocation }) else {
            print("Could not find current index in locations array! Should never happen")
            return
        }
        
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            guard let firstLocation = locations.first else {
                return
            }
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = locations[nextIndex]
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
}


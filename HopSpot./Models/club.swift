//
//  Club.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-05.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

enum busynessType: Int, Codable {
    case Empty
    case Light
    case Moderate
    case Busy
    case VeryBusy
}

struct Club: Codable, Identifiable {
    var id: String
    var name: String
    var address: String
    var rating: Double
    var reviewCount: Int // New field to track the number of reviews
    var description: String
    var imageURL: String
    var latitude: Double
    var longitude: Double
    var busyness: busynessType
    var website: String
    var city: String
    var promotions: [Promotion] = []
    var events: [Event] = []

    init(id: String, name: String, address: String, rating: Double, reviewCount: Int, description: String, imageURL: String, latitude: Double, longitude: Double, busyness: Int, website: String, city: String, promotions: [Promotion] = [], events: [Event] = []) {
        self.id = id
        self.name = name
        self.address = address
        self.rating = rating
        self.reviewCount = reviewCount 
        self.description = description
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.busyness = Club.updateBusyness(from: busyness)
        self.website = website
        self.city = city
        self.promotions = promotions
        self.events = events
    }

    static func updateBusyness(from num: Int) -> busynessType {
        switch num {
        case 0..<10:
            return .Empty
        case 10..<30:
            return .Light
        case 30..<60:
            return .Moderate
        case 60..<90:
            return .Busy
        default:
            return .VeryBusy
        }
    }
    
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
     
    
    func distance(userLocation: CLLocation) -> (distanceKm: Double, estimatedMinutes: Double) {
        let clubLocation = self.location
        let distanceInMeters = userLocation.distance(from: clubLocation)
        let distanceInKm = distanceInMeters / 1_000 // Convert to kilometers
        
        let averageSpeedKmPerHour = 6.4 // Average walking speed
        let estimatedMinutes = (distanceInKm / averageSpeedKmPerHour) * 60.0 // Convert to minutes
        
        return (distanceKm: distanceInKm, estimatedMinutes: estimatedMinutes)
    }
    
    
    // Fetch line reports for the club
    func loadLineReports() async -> [LineReport] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        do {
            let reportsSnapshot = try await Firestore.firestore()
                .collection("Clubs")
                .document(id)
                .collection("lineReports")
                .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
                .whereField("timestamp", isLessThan: endOfDay)
                .order(by: "timestamp", descending: true)
                .limit(to: 3)
                .getDocuments()
             
            return reportsSnapshot.documents.compactMap { document in
                var report = try? document.data(as: LineReport.self)
                report?.id = document.documentID
                return report
            }
        } catch {
            print("DEBUG: Error fetching line reports: \(error.localizedDescription)")
            return []
        }
    }

    // Report line length
    func reportLineLength(option: String, user: User?, completion: @escaping (Bool) -> Void) {
        guard let user = user else {
            completion(false)
            return
        }
        

        let reportRef = Firestore.firestore().collection("Clubs").document(id).collection("lineReports").document()
        let reportId = reportRef.documentID
        let report = LineReport(id: reportId, lineLengthOption: option, timestamp: Date())
        
        do {
            try reportRef.setData(from: report)
            completion(true)
        } catch {
            print("DEBUG: Error submitting line report: \(error.localizedDescription)")
            completion(false)
        }
    }

}

extension Club {
    struct LineReport: Identifiable, Codable {
        var id: String
        var lineLengthOption: String // Updated field name
        var timestamp: Date
    }
}


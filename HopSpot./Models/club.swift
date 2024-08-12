//
//  location.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-05.
//

import Foundation
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

    init(id: String, name: String, address: String, rating: Double, reviewCount: Int, description: String, imageURL: String, latitude: Double, longitude: Double, busyness: Int, website: String, city: String) {
        self.id = id
        self.name = name
        self.address = address
        self.rating = rating
        self.reviewCount = reviewCount // Initialize the new field
        self.description = description
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.busyness = Club.updateBusyness(from: busyness)
        self.website = website
        self.city = city
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
}

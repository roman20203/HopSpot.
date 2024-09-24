//
//  Location.swift
//  HopSpot.
//
//  Created by mina on 2024-07-26.
//

import Foundation
import MapKit
import SwiftUI


struct Location: Identifiable, Equatable {
    let id:String
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: String 
    let link: String
    
    var location_id: String {
        name + cityName
    }
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    
}

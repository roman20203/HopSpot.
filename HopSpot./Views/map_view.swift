//
//  map_view.swift
//  HopSpot.
//
//  Created by Mina Mansour on 2024-07-05.
//

import MapKit
import SwiftUI
import CoreLocation
struct map_view: View {
    @State private var region = MKCoordinateRegion()
    @State private var locationManager = CLLocationManager()
    @State private var venues: [Venue] = []
    var body: some View{
        Map()
        
    }
    
    
    
    
    
    

    struct Venue {
        let name: String
        let location: CLLocationCoordinate2D
    }
    
}

#Preview {
    map_view()
}

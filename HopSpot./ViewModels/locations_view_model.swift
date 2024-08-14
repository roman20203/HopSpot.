//
//  locations_view_model.swift
//  HopSpot.
//
//  Created by mina on 2024-07-27.
//

import Foundation
import MapKit
import SwiftUI


class LocationsViewModel: ObservableObject {
    //all loaded locations
    @Published var locations: [Location]
    //current location on map
    @Published var MapLocation: Location {
        didSet{
            updateMapRegion(location: MapLocation)
        }
    }
    //crurent region on map
    @Published var MapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    //show list of locations
    @Published var showLocationsList: Bool = false
    //show location details via sheet
    @Published var sheetLocation: Location? = nil
    init(){
        let locations = LocationsDataService.locations
        self.locations = locations
        self.MapLocation = locations.first!
        self.updateMapRegion(location: locations .first!)
    }
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut){
            MapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan)
        }
    }
    
    public func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList
        }
    }
    func showNextLocation(location: Location) {
        
        /*
        withAnimation(.easeInOut) {
            MapLocation = location
            showLocationsList = false
        }
         */
        MapLocation = location

        // Perform the animation block separately
        withAnimation(.easeInOut) {
            showLocationsList = false
        }
    }
    func nextButtonPressed() {
        //get current index
        guard let currentIndex = locations.firstIndex(where: { $0 == MapLocation}) else {
            print("Could not find current index in locations array! Should never happen")
            return
        }
        
        //check if current index is valid
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            // Next index is not valid
            //restart from 0
            guard let firstLocation = locations.first else {
                return
            }
            showNextLocation(location: firstLocation)
            return
        }
        
        //Next index is valid
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
}

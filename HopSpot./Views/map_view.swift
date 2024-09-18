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
    @EnvironmentObject private var vm: club_firebase_handler
   
    var body: some View{
        ZStack{
            mapLayer
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                    .padding()
                Spacer()
                locationsPreviewsStack
            }
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            if let club = vm.clubs.first(where: { $0.name == location.name}) {
                club_details_template(club: club)
            }
        }

    }
}

#Preview {
    map_view()
        .environmentObject(club_firebase_handler())
}

extension map_view {
    private var header: some View {
        VStack{
            Button(action:  vm.toggleLocationsList){
                Text(vm.MapLocation.cityName)
                    .font(.title2)
                    .fontWeight((.black))
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: vm.MapLocation)
                     .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
            }
                }
            if vm.showLocationsList {
                LocationsListView()

            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    private var mapLayer: some View {
        Map(coordinateRegion: $vm.MapRegion,
            annotationItems: vm.locations,
            annotationContent: {location in
            MapAnnotation(coordinate: location.coordinates) {
                LocationMapAnnotationView()
                    .scaleEffect(vm.MapLocation == location  ? 1 : 0.7)
                    .shadow(radius: 10)
                    .onTapGesture {
                        vm.showNextLocation(location: location)
                    }
            }
        })
    }
    
    private var locationsPreviewsStack: some View {
        ZStack {
            ForEach(vm.locations) { location in
                if vm.MapLocation == location {
                    location_preview(location: location)
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 20)
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
                
            }
        }
    }
}

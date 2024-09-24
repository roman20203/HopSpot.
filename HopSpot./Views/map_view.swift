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
    @EnvironmentObject private var clubHandler: club_firebase_handler
    
    @State var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
                .onTapGesture {
                    clubHandler.showLocationsList = false
                }
            
            VStack(spacing: 0) {
                header
                    .padding()
                Spacer()
                locationsPreviewsStack
            }
            
        }
        .sheet(item: $clubHandler.sheetLocation) { location in
            if let club = clubHandler.clubs.first(where: { $0.name == location.name }) {
                club_details_template(club: club)
            }
        }
    }

    private var header: some View {
        VStack {
            Button(action: clubHandler.toggleLocationsList) {
                Text(clubHandler.MapLocation.city)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: clubHandler.MapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: clubHandler.showLocationsList ? 180 : 0))
                    }
            }
            if clubHandler.showLocationsList {
                LocationsListView
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    

    private var mapLayer: some View {
        return Map(position: $position) {
            ForEach(clubHandler.clubs, id: \.id) { club in
                Annotation(club.name, coordinate: CLLocationCoordinate2D(latitude: club.latitude, longitude: club.longitude)) {
                    LocationMapAnnotationView()
                        .onTapGesture {
                            clubHandler.updateMapLocation(location:club)
                            clubHandler.updateMapRegion(location: club)
                            withAnimation {
                                position = .region(clubHandler.MapRegion)
                            }
                        }
                }
            }
        }
    }
    
    private var LocationsListView: some View{
        List {
            ForEach(clubHandler.clubs) { location in
                Button {
                    clubHandler.showNextLocation(location: location)
                    withAnimation {
                        position = .region(clubHandler.MapRegion)
                    }
                    
                } label: {
                    listRowView(location: location)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
                    
                }
            }
        .listStyle(PlainListStyle())
    }
    
    private func listRowView(location: Club) -> some View  {
        HStack {
            image_view(imagePath: location.imageURL)
                .frame(width: 45, height: 45)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                Text(location.city)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity,  alignment: .leading)
        }
    }
    
    
    private var locationsPreviewsStack: some View {
        ZStack {
            ForEach(clubHandler.clubs) { club in
                if clubHandler.MapLocation == club {
                    location_preview(location: club)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                        .padding()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        .onTapGesture {
                            clubHandler.showLocationsList = false
                        }
                }
            }
        }
    }
}

#Preview {
    map_view()
        .environmentObject(club_firebase_handler())
}

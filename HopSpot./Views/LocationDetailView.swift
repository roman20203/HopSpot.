//
//  LocationDetailView.swift
//  HopSpot.
//
//  Created by mina on 2024-07-30.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @EnvironmentObject private var vm: club_firebase_handler
    let location: Location
    var body: some View {
        ScrollView {
            VStack {

                imageSection
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                
                VStack(alignment: .leading, spacing: 26) {
                    titleSection
                    Divider()
                    descriptionSection
                    Divider()
                    mapLayer
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .overlay(backButton, alignment: .topLeading)
    }
}


struct LocationDataView_previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: LocationsDataService.locations.first!)
            .environmentObject(club_firebase_handler())
    }
}

extension LocationDetailView {
    private var imageSection: some View {
        TabView {
            Image(location.imageNames) // Directly use the image name
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                        .frame(height: 500)
            
            //Again changes so instead of treating imageNames like [String] we teat it like String
            /*
            ForEach(location.imageNames, id: \.self) {
                Image($0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            }
             */
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(location.cityName)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
           
        }
    }


private var mapLayer: some View {
    Map (coordinateRegion: .constant(MKCoordinateRegion(
        center: location.coordinates,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
         annotationItems: [location]) { location in
        MapAnnotation(coordinate: location.coordinates) {
            LocationMapAnnotationView()
                .shadow(radius: 10)
            }
        }
         .allowsHitTesting(false)
         .aspectRatio(1, contentMode: .fit)
         .cornerRadius(30)
    }
    private var backButton: some View {
        Button {
            vm.sheetLocation = nil
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
            
        }
    }
}

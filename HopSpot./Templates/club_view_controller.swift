//
//  home_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import SwiftUI
import CoreLocation

//Currently this file displays a mock half assed home view just for testing purposes
//the point of this file is so that the near you view can call functions in this file which will display clubs near you, most busy and other categories we decide to add


struct club_view_controller: View {
    @StateObject private var clubHandler = club_firebase_handler()
    @StateObject private var locationManager = UserLocation()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Most Busy")
                        .font(.headline)
                        .padding(.leading)
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(displayPopularClubs(), id: \.id) { club in
                                NavigationLink(destination: club_details_template(club: club)) {
                                    club_view_template(club: club)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Near You")
                        .font(.headline)
                        .padding(.leading)
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(displayNearYouClubs(), id: \.id) { club in
                                NavigationLink(destination: club_details_template(club: club)) {
                                    club_view_template(club: club)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear {
                clubHandler.fetchClubs()
            }
        }
    }
    
    func displayPopularClubs() -> [Club] {
        return clubHandler.clubs.filter { $0.busyness == .VeryBusy || $0.busyness == .Busy }
    }
    
    func displayNearYouClubs() -> [Club] {
        guard let userLocation = locationManager.userLocation else { return [] }

        // Define a distance threshold (e.g., 10 kilometers)
        let distanceThreshold: CLLocationDistance = 50_000_000  // 10 kilometers

        // Filter clubs within the distance threshold
        let nearYouClubs = clubHandler.clubs.filter { club in
            let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
            let distance = clubLocation.distance(from: userLocation)
            return distance <= distanceThreshold
        }

        return nearYouClubs
    }
}

struct club_view_controller_Previews: PreviewProvider {
    static var previews: some View {
        club_view_controller()
    }
}

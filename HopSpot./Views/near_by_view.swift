//
//  near_by_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-09.
//


import SwiftUI
import CoreLocation

struct near_by_view: View {
    @StateObject private var clubHandler = club_firebase_handler()
    @StateObject private var locationManager = UserLocation()
    @State private var searchText = ""
    @State private var showSearchBar = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var filteredClubs: [Club] {
        if searchText.isEmpty {
            return clubHandler.displayNearYouClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 50_000_000_000)
        } else {
            return clubHandler.displayNearYouClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 50_000_000_000)
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if showSearchBar {
                    HStack {
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for custom styling
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white) // White text color
                            .cornerRadius(7) // Rounded corners for the text field
                        
                        Button(action: {
                            showSearchBar = false
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                    .background(Color.black) // Black background for the search bar container
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        if let userLocation = locationManager.userLocation {
                            LazyVStack {
                                ForEach(filteredClubs, id: \.id) { club in
                                    NavigationLink(destination: club_details_template(club: club)) {
                                        club_view_template(club: club)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("Loading location...")
                                .foregroundColor(.white)
                        }
                    }
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            .navigationTitle("Near You.")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchBar.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                clubHandler.fetchClubs()
            }
        }
    }
}

struct near_by_view_Previews: PreviewProvider {
    static var previews: some View {
        near_by_view()
    }
}

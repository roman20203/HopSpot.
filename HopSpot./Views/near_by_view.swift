//
//  near_by_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-09.
//


import SwiftUI
import CoreLocation

struct near_by_view: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @EnvironmentObject var locationManager: UserLocation
    @State private var searchText = ""
    @State private var showSearchBar = false
    
    
    var filteredClubs: [Club] {
        if searchText.isEmpty {
            return clubHandler.displayNearYouClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 5_000)
        } else {
            return clubHandler.displayNearYouClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 5_000)
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
                            .foregroundStyle(.white) // White text color
                            .cornerRadius(7) // Rounded corners for the text field
                        
                        Button(action: {
                            showSearchBar = false
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColor.color)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                    .background(Color.black) // Black background for the search bar container
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        if locationManager.userLocation != nil {
                            LazyVStack {
                                ForEach(filteredClubs, id: \.id) { club in
                                    NavigationLink(destination: club_details_template(club: club)) {
                                        club_view_template(club: club)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("Please Allow Location Services")
                                .foregroundStyle(.white)
                        }
                    }
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            .navigationTitle("Near You.") // Set the title here
            .navigationBarTitleDisplayMode(.large) // Ensure the title display mode is large
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchBar.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColor.color)
                    }
                }
            }
        }
    }
}

struct near_by_view_Previews: PreviewProvider {
    static var previews: some View {
        near_by_view()
            .environmentObject(UserLocation())
            .environmentObject(club_firebase_handler())
        
    }
}

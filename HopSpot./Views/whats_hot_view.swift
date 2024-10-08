//
//  near_by_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-09.
//


import SwiftUI
import CoreLocation

struct whats_hot_view: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @EnvironmentObject var locationManager: UserLocation
    @State private var searchText = ""
    @State private var showSearchBar = false
    
    
    var filteredClubs: [Club] {
        if searchText.isEmpty {
            return clubHandler.displayPopularClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 30_000)//set to 30km
        } else {
            return clubHandler.displayPopularClubs(userLocation: locationManager.userLocation ?? CLLocation(), distanceThreshold: 30_000)
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if showSearchBar {
                    HStack {
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .cornerRadius(7)
                        
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
                    .background(Color.black)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        if locationManager.userLocation != nil {
                            LazyVStack {
                                if filteredClubs.isEmpty{
                                    Text("Nothing happening currently")
                                }
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
            .navigationTitle("What's Hot.")
            .navigationBarTitleDisplayMode(.large)
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

struct whats_hot_view_Previews: PreviewProvider {
    static var previews: some View {
        whats_hot_view()
            .environmentObject(UserLocation())
            .environmentObject(club_firebase_handler())
    }
}

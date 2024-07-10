//
//  ContentView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            home_view()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            map_view()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            notification_view()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            
            profile_view()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
             
        }
    }
}

#Preview {
    ContentView()
}

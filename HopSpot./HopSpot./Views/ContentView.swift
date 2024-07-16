//
//  ContentView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            reg_or_log()
            
        }
        
        
/*
        TabView {
            home_view()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            map_view()
                .tabItem {
                    Label("Search", systemImage: "map")
                }
            
            notification_view()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            
            profile_view()
                .tabItem {
                    Label("Profile", systemImage: "circle")
                }
             
        }
 
 */
    }
}

#Preview {
    ContentView()
}

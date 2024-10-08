//
//  guest_main_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-10-08.
//

import SwiftUI

struct guest_main_view: View {
    @EnvironmentObject var locationManager: UserLocation
    @EnvironmentObject var viewModel: log_in_view_model
    
    var body: some View {
        TabView {
            home_view()
                .tabItem {
                    VStack() {
                        Image(systemName: "house.fill")
                            .foregroundStyle(.white)
                        Text("Home")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    
                }
            
            map_view()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                            .foregroundStyle(.white)
                        Text("Map")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
                .environmentObject(locationManager)
            
            user_promotion_view()
                .tabItem {
                    VStack() {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.white)
                        Text("Promotions")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    
                }
            
            guest_profile_view()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white)
                        Text("Profile")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            
        }
    }
    
}

#Preview {
    guest_main_view()
        .environmentObject(UserLocation())
        .environmentObject(log_in_view_model())
        .environmentObject(club_firebase_handler())
        .preferredColorScheme(.dark)
}

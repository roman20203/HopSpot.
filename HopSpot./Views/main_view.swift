//
//  main_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-08.
//

import SwiftUI

struct main_view: View {
    
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
            
            profile_view()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white)
                        Text("Profile")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
                .environmentObject(viewModel)//gives access to currentUser
            
        }
        //.accentColor(AppColor.color) // Set the color of the selected tab icon
        

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        main_view()
            .environmentObject(UserLocation())
            .environmentObject(log_in_view_model())
            .environmentObject(club_firebase_handler())
    }
}

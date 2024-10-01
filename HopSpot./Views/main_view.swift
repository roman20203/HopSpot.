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
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        
    }
    var body: some View {
        TabView {
            home_view()
                .tabItem {
                    VStack() {
                        Image(systemName: "house.fill")
                            .foregroundColor(.white)
                        Text("Home")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                }

            map_view()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                            .foregroundColor(.white)
                        Text("Map")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .environmentObject(locationManager)
            
            user_promotion_view()
                .tabItem {
                    VStack() {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.white)
                        Text("Promotions")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                }
            
            profile_view()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        Text("Profile")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .environmentObject(viewModel)//gives access to currentUser
            
        }
        .accentColor(AppColor.color) // Set the color of the selected tab icon
        

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

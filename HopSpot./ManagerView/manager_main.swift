//
//  manager_main.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//

import SwiftUI

struct manager_main: View {
    @EnvironmentObject var viewModel: log_in_view_model
    
    init() {

        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        
    }
    var body: some View {
        TabView {
            manager_home_view()
                .tabItem {
                    VStack() {
                        Image(systemName: "house.fill")
                            .foregroundColor(.white)
                        Text("Home")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                }

            other_clubs_view()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                            .foregroundColor(.white)
                        Text("Locations")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }

            PromotionsView()
                .tabItem {
                    VStack {
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                        Text("Promotions")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            manager_profile_view()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                        Text("Profile")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            
        }
        .accentColor(AppColor.color) // Set the color of the selected tab icon

    }
}

struct manager_main_preview: PreviewProvider {
    static var previews: some View {
        manager_main()
            .environmentObject(log_in_view_model())
    }
}

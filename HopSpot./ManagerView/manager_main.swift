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
                            .foregroundStyle(.white)
                        Text("Home")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    
                }
            PromotionsView()
                .tabItem {
                    VStack {
                        Image(systemName: "bell")
                            .foregroundStyle(.white)
                        Text("Promotions")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            EventsView()
                .tabItem {
                    VStack {
                        Image(systemName: "party.popper")
                            .foregroundStyle(.white)
                        Text("Events")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            manager_profile_view()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                            .foregroundStyle(.white)
                        Text("Profile")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            
        }

    }
}

struct manager_main_preview: PreviewProvider {
    static var previews: some View {
        manager_main()
            .environmentObject(log_in_view_model())
    }
}

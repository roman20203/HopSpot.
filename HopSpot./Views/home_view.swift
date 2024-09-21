//
//  home_view.swift
//  HopSpot.
//
//  Created by Yousef H on 2024-08-09.
//

import Foundation
import SwiftUI

struct home_view: View {
    @EnvironmentObject var locationManager: UserLocation
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full screen black background
                Color.black.edgesIgnoringSafeArea(.all)
            
                // Scrollable content
                ScrollView {
                    VStack {
                        HStack {
                            Spacer()
                            Text("HopSpot.")
                                .font(.system(size: 35, weight: .black))
                                .tracking(0.9)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 16)
                        //Spacer()
                    }
                    VStack(alignment: .leading, spacing: 16) { // Adjusted spacing for alignment
                        // Fixed top menu bar and title
                        
                        HStack(){
                            Text("Waterloo, ON")
                                .foregroundStyle(.white)
                            Image(systemName:"location")
                                .foregroundStyle(.white)
                        }
                        
                        NavigationLink(destination: near_by_view()) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Near You.")
                                    .font(Font.custom("Arial", size: 26).weight(.bold))
                                    .tracking(0.78)
                                    .foregroundStyle(.white)
                                
                                Text("Find new spots around you")
                                    .font(Font.custom("Arial", size: 12))
                                    .tracking(0.36)
                                    .foregroundStyle(.white)
                                
                        
                                HStack(spacing: 6) {
                                    Image("IMG_0201")
                                        .resizable()
                                        .frame(width: 100, height: 150)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0202")
                                        .resizable()
                                        .frame(width: 80, height: 130)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0203")
                                        .resizable()
                                        .frame(width: 90, height: 160)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        //Whats Hot
                        NavigationLink(destination: whats_hot_view()) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("What's Hot.")
                                    .font(Font.custom("Arial", size: 26).weight(.bold))
                                    .tracking(0.78)
                                    .foregroundColor(.white)
                                
                                Text("What's trending around you")
                                    .font(Font.custom("Arial", size: 12))
                                    .tracking(0.36)
                                    .foregroundColor(.white)
                                
                            
                                HStack(spacing: 6) {
                                    Image("IMG_0204")
                                        .resizable()
                                        .frame(width: 100, height: 140)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0205")
                                        .resizable()
                                        .frame(width: 90, height: 150)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0206")
                                        .resizable()
                                        .frame(width: 85, height: 135)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 10)
                        }
 
                        // Frat Events
                        NavigationLink(destination: frat_events_view()) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Frat Parties")
                                    .font(Font.custom("Arial", size: 26).weight(.bold))
                                    .tracking(0.78)
                                    .foregroundColor(.white)
                                
                                Text("Upcoming Frat Parties")
                                    .font(Font.custom("Arial", size: 12))
                                    .tracking(0.36)
                                    .foregroundColor(.white)
                                
                                // Image Grid 3
                                HStack(spacing: 6) { // Adjusted spacing between images
                                    Image("IMG_0207")
                                        .resizable()
                                        .frame(width: 100, height: 140)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0208")
                                        .resizable()
                                        .frame(width: 90, height: 160)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0209")
                                        .resizable()
                                        .frame(width: 85, height: 145)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Push images to the left
                            }
                            .padding(.vertical, 10)
                        }
                        
                        // Section 4: CLlub Events
                        NavigationLink(destination: club_events_view()){
                            VStack(alignment: .leading, spacing: 6) { // Adjusted spacing
                                Text("Club Events")
                                    .font(Font.custom("Arial", size: 26).weight(.bold))
                                    .tracking(0.78)
                                    .foregroundColor(.white)
                                
                                Text("Check out current and upcoming club events")
                                    .font(Font.custom("Arial", size: 12))
                                    .tracking(0.36)
                                    .foregroundColor(.white)
                                
                                // Image Grid 4
                                HStack(spacing: 6) { // Adjusted spacing between images
                                    Image("IMG_0210")
                                        .resizable()
                                        .frame(width: 100, height: 140)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0211")
                                        .resizable()
                                        .frame(width: 90, height: 150)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                    Image("IMG_0212")
                                        .resizable()
                                        .frame(width: 85, height: 135)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Push images to the left
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .background(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading) // Push entire VStack to the left
                }
            }
        }
    }
}

struct home_view_Previews: PreviewProvider {
    static var previews: some View {
        home_view()
            .environmentObject(UserLocation())
            .environmentObject(club_firebase_handler())
    }
}

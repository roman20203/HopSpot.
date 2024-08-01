//
//  profile_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top bar with black background and white text
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 90) // Height of the black bar at the top, adjust as needed
                    Text("HopSpot.")
                        .font(.system(size: 30, weight: .black))
                        .tracking(0.9)
                        .foregroundColor(.white)
                        .offset(y: 10) // Adjust the vertical position of the text
                }
                
                // Background image
                Image("IMG_0147")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 395, height: 203) // Width and height of the background image
                    .clipped()
                
                VStack(spacing: -30) {
                    ZStack {
                        // White background for the user info section
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(50)
                            .shadow(radius: 15)
                        
                        VStack(alignment: .leading) {
                            // User profile picture and name section
                            HStack(alignment: .center) {
                                // Profile picture
                                Image("IMG_0141")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90) // Size of the profile picture
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color(red: 0.99, green: 0, blue: 0.54), lineWidth: 2.5)
                                    )
                                    .offset(x: -10, y: -27) // Adjust position of the profile picture
                                
                                VStack(alignment: .leading) {
                                    Text("Nathanscott_23_")
                                        .font(.system(size: 20, weight: .black))
                                        .tracking(0.9)
                                        .foregroundColor(.black)
                                    
                                    Text("Nathan Scott")
                                        .font(.system(size: 17, weight: .black))
                                        .tracking(0.9)
                                        .foregroundColor(.black)
                                }
                                .offset(x: -10, y: -45) // Adjust position of the user name and details
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20) // Adjust left and right padding of the user info section
                            
                            // Buttons for Share and Edit Profile
                            HStack(spacing: 20) {
                                Button(action: {}) {
                                    Text("Share")
                                        .font(Font.custom("Forma DJR Text", size: 12).weight(.bold))
                                        .padding()
                                        .frame(width: 100, height: 30) // Size of the Share button
                                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .cornerRadius(26)
                                }
                                
                                Button(action: {}) {
                                    Text("Edit Profile")
                                        .font(Font.custom("Forma DJR Text", size: 12).weight(.bold))
                                        .padding()
                                        .frame(width: 100, height: 30) // Size of the Edit Profile button
                                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .cornerRadius(26)
                                }
                            }
                            .offset(x: 10, y: -30) // Adjust position of the buttons
                            
                            // User statistics
                            HStack(spacing: 30) {
                                VStack {
                                    Image(systemName: "flame.fill")
                                    Text("2004")
                                }
                                VStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("15 Visits")
                                }
                                VStack {
                                    Image(systemName: "graduationcap.fill")
                                    Text("Wilfred Laurier")
                                }
                            }
                            .font(.system(size: 12, weight: .black))
                            .tracking(0.9)
                            .foregroundColor(.black)
                            .padding(.top, 10) // Adjust top padding of the stats section
                            .padding(.bottom, 20) // Adjust bottom padding of the stats section
                            .offset(x: 15, y: -30) // Adjust position to the middle
                            
                            // First row of images
                            HStack(spacing: 5) {
                                Image("IMG_0139")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the first image in the first row
                                    .cornerRadius(10)
                                
                                
                                Image("IMG_0140")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the second image in the first row
                                    .cornerRadius(10)
                                
                                Image("IMG_0142")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the third image in the first row
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 5) // Adjust bottom padding of the first row of images
                            .padding(.leading, 0) // Adjust left padding of the first row of images
                            
                            // Second row of images
                            HStack(spacing: 5) {
                                Image("jjkhh")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the first image in the second row
                                    .cornerRadius(10)
                                
                                Image("IMG_0149")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the second image in the second row
                                    .cornerRadius(10)
                                
                                Image("IMG_0143")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 112) // Size of the third image in the second row
                                    .cornerRadius(10)
                            }
                            .padding(.leading, 0) // Adjust left padding of the second row of images
                        }
                        .padding()
                    }
                    .padding(.top, -30) // Adjust vertical position of the user info section
                    .frame(height: 535) // Height of the user info section
                    
                    Spacer()
                    
                    // Bottom bar with icons
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.white)
                            Text("Home")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                            Text("Search")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                            Text("Notifications")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            Text("Profile")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .padding(.bottom, 35) // Adjust padding for the bottom safe area
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

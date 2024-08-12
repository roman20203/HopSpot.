//
//  club_details_template.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-01.
//

import SwiftUI
import CoreLocation

struct club_details_template: View {
    @EnvironmentObject var viewModel: log_in_view_model

    
    let club: Club
    
    @EnvironmentObject var userLocation: UserLocation
    @State private var showRatingView = false
    @State private var showReviewView = false
    @State private var hasSubmittedRating = false


    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // Club Image
                    FirebaseImageView(imagePath: club.imageURL)
                        .frame(height: geometry.size.height * 0.3) // Adjust height relative to screen size
                        .cornerRadius(15)
                        .clipped()
                        .shadow(radius: 10)

                    // Club Name and Rating
                    VStack(alignment: .leading, spacing: 5) {
                        Text(club.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<Int(floor(club.rating)), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.yellow)
                            }
                            if club.rating.truncatingRemainder(dividingBy: 1) != 0 {
                                Image(systemName: "star.leadinghalf.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.yellow)
                            }
                            Text("(\(club.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Description
                    Text(club.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 15)

                    // Address Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Address")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(club.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Busyness Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Busyness")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(busynessDescription(for: club.busyness))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Optional: Distance from user (if userLocation is available)
                    if let userLocation = userLocation.userLocation {
                        let distanceInfo = club.distance(userLocation: userLocation)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Distance")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(String(format: "%.1f km | Approx. Time: %.0f mins", distanceInfo.distanceKm, distanceInfo.estimatedMinutes))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    HStack(spacing: 5){
                        //Star rating
                        Button(action: {
                            showRatingView = true
                        }) {
                            Text(hasSubmittedRating ? "Done!" : "Rate Me")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width:90, height:10)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .disabled(hasSubmittedRating)
                        //we must handle incase somehow the user is not signed in
                        //currentUser is a optional variable which means it may be nil
                        //we use an if and else statement to make sure that we dont pass nil
                        //we are sure that it cannot be nil, because this view and the app cannot
                        //be accessed without being signed in 
                        .sheet(isPresented: $showRatingView) {
                            if let currentUser = viewModel.currentUser {
                                StarRatingTemplate(isPresented: $showRatingView, hasSubmittedRating: $hasSubmittedRating,
                                                   club: club, user: currentUser)
                            } else {
                                // Handle the case where currentUser is nil (e.g., show an error message or default view)
                                Text("User not logged in")
                            }
                        }
                        
                        //Written review
                        Button(action: {
                            showReviewView = true
                        }) {
                            Text("Review")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width:90, height:10)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                    }
                    .padding(.horizontal)
                
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 10)
                .frame(width: geometry.size.width) 
            }
            .navigationTitle(club.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func busynessDescription(for busyness: busynessType) -> String {
        switch busyness {
        case .Empty:
            return "Empty"
        case .Light:
            return "Light"
        case .Moderate:
            return "Moderate"
        case .Busy:
            return "Busy"
        case .VeryBusy:
            return "Very Busy"
        }
    }
}

struct club_details_template_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClub = Club(
            id: "1",
            name: "Sample Club",
            address: "123 Main St",
            rating: 4.5,
            reviewCount: 0,
            description: "A great place to have fun.",
            imageURL: "path/to/image.jpg",
            latitude: 0.0,
            longitude: 0.0,
            busyness: 75,
            website: "www.blah.com",
            city: "Waterloo"
        )
        club_details_template(club: sampleClub)
            .environmentObject(UserLocation()) 
            .environmentObject(log_in_view_model())//gives access to currentUser
    }
}

//
//  club_details_template.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-01.
//

import SwiftUI
import CoreLocation

struct club_details_template: View {
    let club: Club
    @EnvironmentObject var userLocation: UserLocation

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

                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground)) // Light background color
                .cornerRadius(15)
                .shadow(radius: 10)
                .frame(width: geometry.size.width) // Ensure the content fits the width of the screen
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
    }
}

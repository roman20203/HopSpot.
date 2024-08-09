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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FirebaseImageView(imagePath: club.imageURL)
                    .frame(height: 200)
                    .clipped()

                Text(club.name)
                    .font(.largeTitle)
                    .padding(.top)

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
                }
                .padding(.vertical)

                Text(club.description)
                    .padding(.vertical)

                Text("Address")
                    .font(.headline)
                    .padding(.top)
                Text(club.address)

                Text("Busyness")
                    .font(.headline)
                    .padding(.top)
                Text(busynessDescription(for: club.busyness))

                Spacer()
            }
            .padding()
        }
        .navigationTitle(club.name)
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

struct club_details_view_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClub = Club(id: "1", name: "Sample Club", address: "123 Main St", rating: 4.5, description: "A great place to have fun.", imageURL: "path/to/image.jpg", latitude: 0.0, longitude: 0.0, busyness: 75, website: "www.blah.com", city:"Waterloo")
        club_details_template(club: sampleClub)
    }
}

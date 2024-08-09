//
//  club_view_template.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-22.
//

import SwiftUI

struct club_view_template: View {
    let club: Club

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            FirebaseImageView(imagePath: club.imageURL)
                //.frame(width: 280, height: 150)
                .frame(width: 350, height: 170)
                .cornerRadius(10)
                .clipped()
            
            VStack(alignment: .leading) {
                Text(club.name)
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding(.bottom, 2)
                
                HStack(spacing: 2) {
                    ForEach(0..<Int(floor(club.rating)), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.yellow)
                    }
                    // To handle half stars
                    if club.rating.truncatingRemainder(dividingBy: 1) != 0 {
                        Image(systemName: "star.leadinghalf.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
        }
        //.frame(width: 280, height: 150)
        .frame(width: 350, height: 170)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}





struct club_view_template_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClub = Club(
            id: "1",
            name: "Sample Club",
            address: "123 Club Lane",
            rating: 2.5,
            description: "This is a sample club description. It's a great place to hang out and enjoy some music.",
            imageURL: "rabbit_logo",
            latitude: 37.7749,
            longitude: -122.4194,
            busyness: 60,
            website: "https.www.ljfnsdlj.com/",
            city: "Waterloo, ON"
        )
        club_view_template(club: sampleClub)
    }
}



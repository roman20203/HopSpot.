//
//  StarRatingTemplate.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-12.
//

import SwiftUI

struct StarRatingTemplate: View {
    @StateObject private var clubHandler = club_firebase_handler()
    @Binding var isPresented: Bool
    @Binding var hasSubmittedRating: Bool
    let club: Club
    let user: User
    @State private var rating: Int = 0
    @State private var showRatingMessage: Bool = false // New state for showing rating message

    var body: some View {
        VStack(spacing: 20) {
            Text("Leave a Star Rating")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                ForEach(1..<6) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = index
                        }
                }
            }

            Button(action: {
                // Attempt to submit the rating
                clubHandler.submitRating(for: club, newRating: rating, userId: user.id) { success in
                    if success {
                        hasSubmittedRating = true
                        isPresented = false
                    } else {
                        showRatingMessage = true
                    }
                }
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            // Message for already submitted rating
            if showRatingMessage {
                Text("You've already submitted a rating today.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }
}


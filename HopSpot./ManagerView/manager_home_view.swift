//
//  manager_home_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct manager_home_view: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var averageRating: Double = 0.0
    @State private var reviewCount: Int = 0
    @State private var recentRatings: [StarReview] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Club Name
                Text(viewModel.currentManager?.activeBusiness?.name ?? "Your Club")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top)

                // Star Rating and Review Count
                HStack(spacing: 2) {
                    ForEach(0..<Int(floor(averageRating)), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.yellow)
                    }
                    if averageRating.truncatingRemainder(dividingBy: 1) != 0 {
                        Image(systemName: "star.leadinghalf.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.yellow)
                    }
                    Text("(\(reviewCount))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                // Recent Ratings
                VStack(alignment: .leading) {
                    Text("Recent Ratings")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.bottom, 10)

                    ForEach(recentRatings) { review in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Rating:")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(Int(review.rating))") // Remove decimal places
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                            }
                        Text("Time: \(review.timestamp)")
                            .font(.caption)
                            .foregroundStyle(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                        RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Manager Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadRatingAndReviewCount()
                await loadRecentRatings() // Load recent ratings
            }
        }
    }

    private func loadRatingAndReviewCount() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }

        do {
            let clubDocument = try await Firestore.firestore().collection("Clubs").document(clubId).getDocument()
            if let data = clubDocument.data() {
                averageRating = data["rating"] as? Double ?? 0.0
                reviewCount = data["reviewCount"] as? Int ?? 0
            }
        } catch {
            print("DEBUG: Failed to load rating and review count with error: \(error.localizedDescription)")
        }
    }

    private func loadRecentRatings() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }

        do {
            let reviewsSnapshot = try await Firestore.firestore().collection("Clubs").document(clubId).collection("StarReviews").order(by: "timestamp", descending: true).limit(to: 10).getDocuments()
            recentRatings = reviewsSnapshot.documents.compactMap { try? $0.data(as: StarReview.self) }
        } catch {
            print("DEBUG: Failed to load recent ratings with error: \(error.localizedDescription)")
        }
    }
}

// Assuming you have a StarReview model
struct StarReview: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String?
    let rating: Double
    let timestamp: Date
}

#Preview {
    manager_home_view()
        .environmentObject(log_in_view_model())
}

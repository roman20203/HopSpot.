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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Club Name
                Text(viewModel.currentManager?.activeBusiness?.name ?? "Your Club")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary) // Adapts to light and dark mode
                    .padding(.top)
                
                // Star Rating and Review Count
                HStack(spacing: 2) {
                    ForEach(0..<Int(floor(averageRating)), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                    }
                    if averageRating.truncatingRemainder(dividingBy: 1) != 0 {
                        Image(systemName: "star.leadinghalf.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                    }
                    Text("(\(reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea()) // Adapts to light and dark mode
            .navigationTitle("Manager Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadRatingAndReviewCount()
            }
        }
    }
    
    private func loadRatingAndReviewCount() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }
        
        do {
            let clubDocument = try await Firestore.firestore().collection("Clubs").document(clubId).getDocument()
            if let data = clubDocument.data() {
                averageRating = data["rating"] as? Double ?? 0.0
                
                let ratingsSnapshot = try await Firestore.firestore().collection("Clubs").document(clubId).collection("Rating").getDocuments()
                reviewCount = ratingsSnapshot.documents.count
            }
        } catch {
            print("DEBUG: Failed to load rating and review count with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    manager_home_view()
        .environmentObject(log_in_view_model())
}

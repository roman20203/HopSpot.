//
//  InAppClubSelection.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct InAppClubSelection: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedClub: Business?
    @State private var businesses: [Business] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Your Club")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                List(businesses, id: \.id) { business in
                    Button(action: {
                        selectedClub = business
                        Task {
                            await viewModel.setActiveBusiness(for: business)
                            // Dismiss the view
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "building.2.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(AppColor.color)
                                .padding(.trailing, 10)
                            
                            Text(business.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isActiveClub(business) ? AppColor.color.opacity(0.2) : Color(uiColor: .systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.color, lineWidth: isActiveClub(business) ? 3 : 2)
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .task {
                await loadBusinesses()
            }
        }
    }

    private func loadBusinesses() async {
        guard let businessIds = viewModel.currentManager?.businessIds else { return }

        for businessId in businessIds {
            do {
                let businessSnapshot = try await Firestore.firestore().collection("Businesses").document(businessId).getDocument()
                if let business = try businessSnapshot.data(as: Business?.self) {
                    businesses.append(business)
                } else {
                    print("DEBUG: Business data is nil for ID \(businessId)")
                }
            } catch {
                print("DEBUG: Failed to load business with ID \(businessId) with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func isActiveClub(_ business: Business) -> Bool {
        return viewModel.currentManager?.activeBusiness?.id == business.id
    }
}

#Preview {
    InAppClubSelection()
        .environmentObject(log_in_view_model())
}

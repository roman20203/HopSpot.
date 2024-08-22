//
//  ClubSelectionView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//


import Firebase
import FirebaseFirestoreSwift
import SwiftUI

struct ClubSelectionView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var selectedClub: Business?
    @State private var businesses: [Business] = [] // Array to store Business objects
    @State private var navigateToManagerMain = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Your Club")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                List(businesses, id: \.id) { business in
                    Button(action: {
                        selectedClub = business
                        Task {
                            await viewModel.setActiveBusiness(for: business)
                            navigateToManagerMain = true
                        }
                    }) {
                        HStack {
                            // Placeholder for a club logo or icon
                            Image(systemName: "building.2.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(AppColor.color)
                                .padding(.trailing, 10)
                            
                            Text(business.name) // Display business name
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.6)) // Updated to black with opacity
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.color, lineWidth: 2)
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToManagerMain) {
                NavigationStack { // New NavigationStack to reset the stack
                    manager_main()
                }
                .navigationBarBackButtonHidden(true)
            }
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
}

#Preview {
    ClubSelectionView()
        .environmentObject(log_in_view_model())
}

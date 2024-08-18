//
//  ClubSelectionView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-14.
//

/*

import SwiftUI


struct ClubSelectionView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var selectedClubId: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            if let businessIds = viewModel.currentManager?.businessIds {
                List(businessIds, id: \.self) { businessId in
                    Button(action: {
                        selectedClubId = businessId
                        selectClub(businessId: businessId)
                    }) {
                        Text(businessId)
                    }
                }
                .padding()
            } else {
                Text("No clubs available")
                    .padding()
            }

            if let selectedClubId = selectedClubId {
                Text("Selected Club: \(selectedClubId)")
                    .padding()
            }

            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Select Your Club")
    }

    private func selectClub(businessId: String) {
        Task {
            do {
                try await viewModel.updateActiveBusiness(businessId: businessId)
                // Proceed to the next view or update the state as needed
            } catch {
                alertMessage = "Failed to select club: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#Preview {
    ClubSelectionView()
        .environmentObject(log_in_view_model()) // Provide a preview environment object
}
*/

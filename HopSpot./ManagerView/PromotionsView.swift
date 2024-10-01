//
//  PromotionsView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PromotionsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var selectedSection: String = "Tonight"
    @State private var showCreateView = false

    var body: some View {
        VStack {
            Picker("Select Section", selection: $selectedSection) {
                Text("Tonight").tag("Tonight")
                Text("Upcoming").tag("Upcoming")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .tint(AppColor.color)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            
            Spacer()
            
            if selectedSection == "Tonight" {
                TonightUserPromotionsView(promos: filteredClubPromotions(for: clubHandler.currentPromotions))
            } else {
                UpcomingUserPromotionsView(promos: filteredClubPromotions(for: clubHandler.upcomingPromotions))
            }

            // Plus button for creating a new promotion
            Button(action: {
                showCreateView = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .background(Color(UIColor.systemBackground).opacity(0.7)) // Adapt to light and dark mode
                    .clipShape(Circle())
                    .foregroundColor(AppColor.color) // Custom color
                    .padding()
            }
            .sheet(isPresented: $showCreateView) {
                PromotionCreateView(
                    clubName: viewModel.currentManager?.activeBusiness?.name ?? "No Club",
                    clubImageURL: viewModel.currentManager?.activeBusiness?.imageURL ?? "placeholder_image_url",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
        .navigationTitle("Promotions")
        .padding()
    }
    
    private func filteredClubPromotions(for promos: [Promotion]) -> [Promotion] {
        // Ensure the user manager has a Club
        print("User: \(String(describing: viewModel.currentManager?.name))")
        print("Club Name: \(String(describing: viewModel.currentManager?.activeBusiness?.name))")
        
        guard let club_Name = viewModel.currentManager?.activeBusiness?.name else {
            return [] // Return an empty array if the user is not a Manager
        }
        return promos.filter { $0.clubName == club_Name }
    }
}

struct TonightUserPromotionsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var selectedPromo: Promotion? // To store the selected promotion for editing
    var promos: [Promotion]

    var body: some View {
        if promos.isEmpty {
            Text("No Promotions Tonight")
                .foregroundStyle(.primary)
                .padding()
            Spacer()
        } else {
            ScrollView {
                ForEach(promos) { promo in
                    Button(action: {
                        selectedPromo = promo // Set the selected promotion
                    }) {
                        Promotion_Cell(promotion: promo)
                            .padding(.bottom, 10)
                    }
                }
            }
            .sheet(item: $selectedPromo) { promo in // Present the edit view as a sheet
                PromotionEditView(
                    promotion: promo,
                    clubName: promo.clubName ?? "",
                    clubImageURL: promo.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
    }
}

struct UpcomingUserPromotionsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var selectedPromo: Promotion? // To store the selected promotion for editing
    var promos: [Promotion]

    var body: some View {
        if promos.isEmpty {
            Text("No Upcoming Promotions")
                .foregroundStyle(.primary)
                .padding()
            Spacer()
        } else {
            ScrollView {
                ForEach(promos) { promo in
                    Button(action: {
                        selectedPromo = promo // Set the selected promotion
                    }) {
                        Promotion_Cell(promotion: promo)
                            .padding(.bottom, 10)
                    }
                }
            }
            .sheet(item: $selectedPromo) { promo in // Present the edit view as a sheet
                PromotionEditView(
                    promotion: promo,
                    clubName: promo.clubName ?? "",
                    clubImageURL: promo.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
    }
}

#Preview {
    PromotionsView()
        .environmentObject(log_in_view_model())
}

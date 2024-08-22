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
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var promotions: [Promotion] = []
    @State private var selectedPromotion: Promotion?
    @State private var isEditingPromotion = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(promotions) { promotion in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(promotion.title)
                                    .font(.headline)
                                    .foregroundColor(.primary) // Adapts to light and dark mode
                                Text(promotion.description)
                                    .font(.subheadline)
                                    .foregroundColor(.primary) // Adapts to light and dark mode
                                if let link = promotion.link, !link.isEmpty {
                                    Link("View Tickets", destination: URL(string: link)!)
                                        .font(.subheadline)
                                        .foregroundColor(AppColor.color) // Highlight color
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground).opacity(0.8)) // Adapts to light and dark mode
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedPromotion = promotion
                            isEditingPromotion = true
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .task {
                    await loadPromotions()
                }
                Spacer()
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea()) // Adapts to light and dark mode
            .navigationTitle("Promotions")
            .sheet(isPresented: $isEditingPromotion) {
                PromotionEditView(promotion: .constant(selectedPromotion)) {
                    // Reload promotions after saving
                    Task {
                        await loadPromotions()
                    }
                }
            }
            .overlay(
                Button(action: {
                    selectedPromotion = nil
                    isEditingPromotion = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .background(Color(uiColor: .secondarySystemBackground).opacity(0.7)) // Adapts to light and dark mode
                        .clipShape(Circle())
                        .foregroundColor(AppColor.color) // Highlight color
                        .padding()
                }
                .padding(),
                alignment: .bottomTrailing
            )
        }
    }

    private func loadPromotions() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }
        
        do {
            let promotionsSnapshot = try await Firestore.firestore().collection("Clubs").document(clubId).collection("Promotions").getDocuments()
            promotions = promotionsSnapshot.documents.compactMap { try? $0.data(as: Promotion.self) }
        } catch {
            print("DEBUG: Failed to load promotions with error: \(error.localizedDescription)")
        }
    }
}
#Preview {
    PromotionsView()
        .environmentObject(log_in_view_model())
}

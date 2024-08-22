//
//  PromotionEditView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PromotionEditView: View {
    @Binding var promotion: Promotion?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600 * 24)
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600 * 24)
    @State private var link: String = ""
    @State private var showDeleteConfirmation = false
    @EnvironmentObject var viewModel: log_in_view_model
    @Environment(\.presentationMode) var presentationMode
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Promotion Details").foregroundColor(.white)) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    TextField("Link (optional)", text: $link)
                        .keyboardType(.URL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    Task {
                        await savePromotion()
                    }
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColor.color)
                        .cornerRadius(8)
                }
                .disabled(title.isEmpty || description.isEmpty)

                if promotion != nil {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete Promotion")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(promotion == nil ? "New Promotion" : "Edit Promotion")
            .onAppear {
                if let promotion = promotion {
                    title = promotion.title
                    description = promotion.description
                    startDate = promotion.startDate
                    endDate = promotion.endDate
                    startTime = promotion.startTime
                    endTime = promotion.endTime
                    link = promotion.link ?? ""
                } else {
                    // Initialize fields for a new promotion
                    title = ""
                    description = ""
                    startDate = Date()
                    endDate = Date().addingTimeInterval(3600 * 24)
                    startTime = Date()
                    endTime = Date().addingTimeInterval(3600 * 24)
                    link = ""
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this promotion?"),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            await deletePromotion()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func savePromotion() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }

        let startDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: startTime),
                                                  minute: Calendar.current.component(.minute, from: startTime),
                                                  second: 0,
                                                  of: startDate) ?? startDate
        let endDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: endTime),
                                                minute: Calendar.current.component(.minute, from: endTime),
                                                second: 0,
                                                of: endDate) ?? endDate

        let newPromotion = Promotion(id: promotion?.id, title: title, description: description, startDate: startDateTime, endDate: endDateTime, startTime: startTime, endTime: endTime, link: link)
    
        do {
            if let id = newPromotion.id {
                try Firestore.firestore().collection("Clubs").document(clubId).collection("Promotions").document(id).setData(from: newPromotion)
            } else {
                _ = try Firestore.firestore().collection("Clubs").document(clubId).collection("Promotions").addDocument(from: newPromotion)
            }
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("DEBUG: Failed to save promotion with error: \(error.localizedDescription)")
        }
    }

    private func deletePromotion() async {
        guard let id = promotion?.id, let clubId = viewModel.currentManager?.activeBusiness?.club_id else { return }

        do {
            try await Firestore.firestore().collection("Clubs").document(clubId).collection("Promotions").document(id).delete()
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("DEBUG: Failed to delete promotion with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PromotionEditView(promotion: .constant(nil)) {}
        .environmentObject(log_in_view_model())
}


//
//  PromotionEditView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct PromotionEditView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    var promotion: Promotion
    var clubName: String
    var clubImageURL: String
    var onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode

    // State variables for editing the promotion
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var link: String
    
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation: Bool = false // State for delete confirmation

    // Initialize state variables with existing promotion data
    init(promotion: Promotion, clubName: String, clubImageURL: String, onSave: @escaping () -> Void) {
        self.promotion = promotion
        self.clubName = clubName
        self.clubImageURL = clubImageURL
        self.onSave = onSave

        // Pre-populate state variables with the promotion data
        _title = State(initialValue: promotion.title)
        _description = State(initialValue: promotion.description)
        _startDate = State(initialValue: promotion.startDate)
        _endDate = State(initialValue: promotion.endDate)
        _startTime = State(initialValue: promotion.startTime)
        _endTime = State(initialValue: promotion.endTime)
        _link = State(initialValue: promotion.link ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Promotion Details")) {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()

                    TextField("Description", text: $description)
                        .autocorrectionDisabled()

                    TextField("Link", text: $link)
                        .autocorrectionDisabled()

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                Section(header: Text("Start Date/Time")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())

                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                }
                
                Section(header: Text("End Date/Time")) {
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())

                    DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                }
                
                Button("Delete") {
                    showDeleteConfirmation = true // Show the confirmation alert
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Edit Promotion")
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveChanges()
                            if errorMessage == nil || errorMessage!.isEmpty {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .foregroundStyle(AppColor.color)
                }
            }
            .alert(isPresented: $showDeleteConfirmation) { // Alert for deletion confirmation
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Do you really want to delete this promotion? This action cannot be undone."),
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

    private func saveChanges() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No Active Club ID found")
            return
        }

        // Basic validation
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty."
            return
        }
        
        // Extract the date components to compare only the day
        let calendar = Calendar.current
        let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)

        // Create Dates from DateComponents for comparison
        guard let startDateOnly = calendar.date(from: startDateComponents),
              let endDateOnly = calendar.date(from: endDateComponents) else {
            errorMessage = "Invalid date components."
            return
        }

        // Compare only the date components
        if startDateOnly > endDateOnly {
            errorMessage = "Start date must be before end date."
            return
        } else if startDateOnly == endDateOnly {
            // Extract time components to compare only the time
            let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)

            // Create Dates from time components for comparison
            let startTimeOnly = calendar.date(from: startTimeComponents)
            let endTimeOnly = calendar.date(from: endTimeComponents)

            if let start = startTimeOnly, let end = endTimeOnly, start > end {
                errorMessage = "Start time must be before end time."
                return
            }
        }

        let updatedPromotion = Promotion(
            id: promotion.id,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            link: link,
            clubName: clubName,
            clubImageURL: clubImageURL
            
        )

        do {
            let db = Firestore.firestore()
            if let promotionId = updatedPromotion.id {
                try await db.collection("Clubs").document(clubId).collection("Promotions").document(promotionId).setData([
                    "title": updatedPromotion.title,
                    "description": updatedPromotion.description,
                    "startDate": Timestamp(date: updatedPromotion.startDate),
                    "endDate": Timestamp(date: updatedPromotion.endDate),
                    "startTime": Timestamp(date: updatedPromotion.startTime),
                    "endTime": Timestamp(date: updatedPromotion.endTime),
                    "clubName": updatedPromotion.clubName ?? "",
                    "clubImageURL": updatedPromotion.clubImageURL ?? "",
                    "link": updatedPromotion.link ?? ""
                ], merge: true)

                errorMessage = ""
                onSave()
            }
        } catch {
            print("DEBUG: Failed to update promotion with error: \(error.localizedDescription)")
        }
    }
    
    private func deletePromotion() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No Active Club ID found")
            return
        }

        do {
            let db = Firestore.firestore()
            if let promotionId = promotion.id {
                // Delete the promotion document from Firestore
                try await db.collection("Clubs").document(clubId).collection("Promotions").document(promotionId).delete()
                
                // Optionally, notify the parent view to refresh or handle the deletion
                onSave()
                presentationMode.wrappedValue.dismiss() // Dismiss the view after deletion
            }
        } catch {
            print("DEBUG: Failed to delete promotion with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PromotionEditView(
        promotion: Promotion(
            id: "sample_id",
            title: "Sample Promotion",
            description: "This is a sample description",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600 * 24),
            link: "https://example.com",
            clubName: "Sample Frat",
            clubImageURL: "placeholder_image_url"
        ),
        clubName: "Sample Frat",
        clubImageURL: "placeholder_image_url",
        onSave: {}
    )
    .environmentObject(log_in_view_model())
}

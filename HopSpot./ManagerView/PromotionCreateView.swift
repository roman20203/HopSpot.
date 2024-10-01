//
//  PromotionFormView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct PromotionCreateView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    var clubName: String
    var clubImageURL: String
    var onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600 * 24)
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600 * 24)
    @State private var link = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
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
                                .foregroundStyle(.red)
                                .padding()
                        }
                    }
                    Section(header: Text("Start Date/Time")){
                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                        DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    }
                    
                    Section(header: Text("End Date/Time")){
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            
                        DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    }
                }
                .navigationTitle("New Promotion")
                .background(Color.black.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                await savePromotion()
                                if errorMessage == "" {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .foregroundStyle(AppColor.color)
                    }
                }
            }
        }
    }

    private func savePromotion() async {
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

        let newPromotion = Promotion(
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
            let _ = try await db.collection("Clubs").document(clubId).collection("Promotions").addDocument(data: [
                "title": newPromotion.title,
                "description": newPromotion.description,
                "startDate": Timestamp(date: newPromotion.startDate),
                "endDate": Timestamp(date: newPromotion.endDate),
                "startTime": Timestamp(date: newPromotion.startTime),
                "endTime": Timestamp(date: newPromotion.endTime),
                "link": newPromotion.link ?? "",
                "clubName": newPromotion.clubName ?? "",
                "clubImageURL": newPromotion.clubImageURL ?? ""
                
            ])
            
            errorMessage = ""
            onSave()
        } catch {
            print("DEBUG: Failed to save promotion with error: \(error.localizedDescription)")
            errorMessage = "Failed to create promotion. Please try again."
        }
    }
}

#Preview {
    PromotionCreateView(clubName: "Sample Club", clubImageURL: "placeholder_image_url") {}
        .environmentObject(log_in_view_model())
}

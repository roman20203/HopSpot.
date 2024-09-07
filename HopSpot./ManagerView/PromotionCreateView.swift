//
//  PromotionFormView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PromotionCreateView: View {
    var clubName: String
    var clubImageURL: String
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600 * 24)
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600 * 24)
    @State private var link: String = ""
    @EnvironmentObject var viewModel: log_in_view_model
    @Environment(\.presentationMode) var presentationMode
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Promotion Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    
                    TextField("Link (optional)", text: $link)
                }
            }
            .navigationTitle("New Promotion")
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await savePromotion()
                        }
                    }
                    .foregroundStyle(AppColor.color)
                }
            }
        }
    }

    private func savePromotion() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No club ID found")
            return
        }

        let startDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: startTime),
                                                  minute: Calendar.current.component(.minute, from: startTime),
                                                  second: 0,
                                                  of: startDate) ?? startDate
        let endDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: endTime),
                                                minute: Calendar.current.component(.minute, from: endTime),
                                                second: 0,
                                                of: endDate) ?? endDate

        let newPromotion = Promotion(
            id: nil, // New promotion has no ID yet
            title: title,
            description: description,
            startDate: startDateTime,
            endDate: endDateTime,
            startTime: startTime,
            endTime: endTime,
            link: link,
            clubName: clubName,
            clubImageURL: clubImageURL
        )
        
        do {
            _ = try Firestore.firestore().collection("Clubs").document(clubId).collection("Promotions").addDocument(from: newPromotion)
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("DEBUG: Failed to save promotion with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PromotionCreateView(clubName: "Sample Club", clubImageURL: "placeholder_image_url", onSave: {})
        .environmentObject(log_in_view_model())
}

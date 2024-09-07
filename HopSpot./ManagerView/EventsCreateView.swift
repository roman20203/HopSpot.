//
//  EventsCreateView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct EventsCreateView: View {
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
    @State private var location = ""
    @State private var link = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    TextField("Location", text: $location)
                    TextField("Link", text: $link)
                }
            }
            .navigationTitle("New Event")
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveEvent()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .foregroundStyle(AppColor.color)
                }
            }
        }
    }

    private func saveEvent() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No club ID found")
            return
        }

        let newEvent = Event(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            location: location,
            clubName: clubName,
            clubImageURL: clubImageURL,
            link: link
        )

        do {
            let db = Firestore.firestore()
            let _ = try await db.collection("Clubs").document(clubId).collection("Events").addDocument(data: [
                "title": newEvent.title,
                "description": newEvent.description,
                "startDate": Timestamp(date: newEvent.startDate),
                "endDate": Timestamp(date: newEvent.endDate),
                "startTime": Timestamp(date: newEvent.startTime),
                "endTime": Timestamp(date: newEvent.endTime),
                "location": newEvent.location,
                "clubName": newEvent.clubName ?? "",
                "clubImageURL": newEvent.clubImageURL ?? "",
                "link": newEvent.link ?? ""
            ])
            
            onSave()
        } catch {
            print("DEBUG: Failed to save event with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EventsCreateView(clubName: "Sample Club", clubImageURL: "placeholder_image_url") {}
        .environmentObject(log_in_view_model())
}

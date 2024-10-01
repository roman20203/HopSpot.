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
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {

                Form {
                    Section(header: Text("Event Details")) {
                        TextField("Title", text: $title)
                            .autocorrectionDisabled()
                            

                        TextField("Description", text: $description)
                            .autocorrectionDisabled()
                            
                            
                        TextField("Location", text: $location)
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
                        // Calendar-style Date Picker for Start Date
                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                        // Time Picker for Start Time
                        DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                            
            
                    }
                    
                    Section(header: Text("End Date/Time")){
                        // Calendar-style Date Picker for End Date
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            

                        // Time Picker for End Time
                        DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    }
                    
    
                    
                }
                .navigationTitle("New Event")
                .background(Color.black.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                await saveEvent()
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

    private func saveEvent() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No Active Club ID found")
            return
        }

        // Basic validation
        guard !title.isEmpty, !location.isEmpty else {
            errorMessage = "Title and location cannot be empty."
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
            
            errorMessage = ""
            onSave()
        } catch {
            print("DEBUG: Failed to save event with error: \(error.localizedDescription)")
            errorMessage = "Failed to create event. Please try again."
        }
    }
}

#Preview {
    EventsCreateView(clubName: "Sample Club", clubImageURL: "placeholder_image_url") {}
        .environmentObject(log_in_view_model())
}

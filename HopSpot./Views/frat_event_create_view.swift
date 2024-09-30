//
//  FratEventCreate.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-26.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct frat_event_create_view: View {
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
                                .foregroundColor(.red)
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
        guard let fratId = viewModel.currentUser?.frat?.id else {
            print("DEBUG: No club ID found")
            return
        }

        // Basic validation
        guard !title.isEmpty, !location.isEmpty else {
            errorMessage = "Title and location cannot be empty."
            return
        }

        if startDate >= endDate {
            errorMessage = "Start date/time must be before end date/time."
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
            let _ = try await db.collection("Waterloo_Frats").document(fratId).collection("Events").addDocument(data: [
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
            errorMessage = "Failed to save event. Please try again."
        }
    }
}


#Preview {
    frat_event_create_view(clubName: "Sample Club", clubImageURL: "placeholder_image_url") {}
        .environmentObject(log_in_view_model())
}

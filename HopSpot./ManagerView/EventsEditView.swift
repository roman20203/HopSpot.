//
//  EventsEditView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct EventsEditView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    var event: Event
    var clubName: String
    var clubImageURL: String
    var onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode

    // State variables for editing the event
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var location: String
    @State private var link: String
    
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation: Bool = false // State for delete confirmation

    // Initialize state variables with existing event data
    init(event: Event, clubName: String, clubImageURL: String, onSave: @escaping () -> Void) {
        self.event = event
        self.clubName = clubName
        self.clubImageURL = clubImageURL
        self.onSave = onSave

        // Pre-populate state variables with the event data
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description)
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _startTime = State(initialValue: event.startTime)
        _endTime = State(initialValue: event.endTime)
        _location = State(initialValue: event.location)
        _link = State(initialValue: event.link ?? "")
    }

    var body: some View {
        NavigationStack {
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
                .foregroundStyle(.red)
            }
            .navigationTitle("Edit Event")
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveChanges()
                            if errorMessage == "" {
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
                    message: Text("Do you really want to delete this event? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            await deleteEvent()
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

        let updatedEvent = Event(
            id: event.id,
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
            if let eventId = updatedEvent.id {
                try await db.collection("Clubs").document(clubId).collection("Events").document(eventId).setData([
                    "title": updatedEvent.title,
                    "description": updatedEvent.description,
                    "startDate": Timestamp(date: updatedEvent.startDate),
                    "endDate": Timestamp(date: updatedEvent.endDate),
                    "startTime": Timestamp(date: updatedEvent.startTime),
                    "endTime": Timestamp(date: updatedEvent.endTime),
                    "location": updatedEvent.location,
                    "clubName": updatedEvent.clubName ?? "",
                    "clubImageURL": updatedEvent.clubImageURL ?? "",
                    "link": updatedEvent.link ?? ""
                ], merge: true)

                errorMessage = ""
                onSave()
            }
        } catch {
            print("DEBUG: Failed to update event with error: \(error.localizedDescription)")
        }
    }
    
    private func deleteEvent() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No Active Club ID found")
            return
        }

        do {
            let db = Firestore.firestore()
            if let eventId = event.id {
                // Delete the event document from Firestore
                try await db.collection("Clubs").document(clubId).collection("Events").document(eventId).delete()
                
                // Optionally, notify the parent view to refresh or handle the deletion
                onSave()
                presentationMode.wrappedValue.dismiss() // Dismiss the view after deletion
            }
        } catch {
            print("DEBUG: Failed to delete event with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EventsEditView(
        event: Event(
            title: "Sample Event",
            description: "This is a sample description",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600 * 24),
            location: "Sample Location",
            clubName: "Sample Frat",
            clubImageURL: "placeholder_image_url",
            link: "https://example.com"
        ),
        clubName: "Sample Frat",
        clubImageURL: "placeholder_image_url",
        onSave: {}
    )
    .environmentObject(log_in_view_model())
}

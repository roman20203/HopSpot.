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
    @Binding var event: Event?
    var onSave: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var location = ""
    @State private var link = ""
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

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
                    TextField("Link (optional)", text: $link)
                }

                if event != nil {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete Event")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(event == nil ? "New Event" : "Edit Event")
            .onAppear {
                if let event = event {
                    title = event.title
                    description = event.description
                    startDate = event.startDate
                    endDate = event.endDate
                    startTime = event.startTime
                    endTime = event.endTime
                    location = event.location
                    link = event.link ?? ""
                } else {
                    resetFields()
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this event?"),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            await deleteEvent()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveEvent()
                        }
                    }
                    .foregroundStyle(AppColor.color)
                }
            }
        }
    }

    private func saveEvent() async {
        guard let eventId = event?.id, let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No event ID or club ID found")
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

        let updatedEvent = Event(
            id: eventId,
            title: title,
            description: description,
            startDate: startDateTime,
            endDate: endDateTime,
            startTime: startTime,
            endTime: endTime,
            location: location,
            clubName: event?.clubName,
            clubImageURL: event?.clubImageURL,
            link: link
        )
        
        do {
            try Firestore.firestore().collection("Clubs").document(clubId).collection("Events").document(eventId).setData(from: updatedEvent)
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("DEBUG: Failed to update event with error: \(error.localizedDescription)")
        }
    }

    private func deleteEvent() async {
        guard let id = event?.id, let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No event ID or club ID found")
            return
        }

        do {
            try await Firestore.firestore().collection("Clubs").document(clubId).collection("Events").document(id).delete()
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("DEBUG: Failed to delete event with error: \(error.localizedDescription)")
        }
    }

    private func resetFields() {
        title = ""
        description = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(3600 * 24)
        startTime = Date()
        endTime = Date().addingTimeInterval(3600 * 24)
        location = ""
        link = ""
    }
}

#Preview {
    EventsEditView(event: .constant(nil), onSave: {})
        .environmentObject(log_in_view_model())
}

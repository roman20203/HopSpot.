//
//  EventsView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//

import SwiftUI
import Firebase

struct EventsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var selectedSection: String = "Tonight"
    @State private var showCreateView = false

    var body: some View {
        VStack {
            Picker("Select Section", selection: $selectedSection) {
                Text("Tonight").tag("Tonight")
                Text("Upcoming").tag("Upcoming")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .tint(AppColor.color)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            
            Spacer()
            
            if selectedSection == "Tonight" {
                TonightUserEventsView(events: filteredClubEvents(for: clubHandler.currentEvents))
            } else {
                UpcomingUserEventsView(events: filteredClubEvents(for: clubHandler.upcomingEvents))
            }

            // Plus button for creating a new event
            Button(action: {
                showCreateView = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .background(Color(UIColor.systemBackground).opacity(0.7)) // Adapt to light and dark mode
                    .clipShape(Circle())
                    .foregroundStyle(AppColor.color) // Custom color
                    .padding()
            }
            .sheet(isPresented: $showCreateView) {
                EventsCreateView(
                    clubName: viewModel.currentManager?.activeBusiness?.name ?? "No Club",
                    clubImageURL: viewModel.currentManager?.activeBusiness?.imageURL ?? "placeholder_image_url",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
        .navigationTitle("Frat Events")
        .padding()
    }
    
    private func filteredClubEvents(for events: [Event]) -> [Event] {
        // Ensure the user manager has a Club
        print("User: \(String(describing: viewModel.currentUser?.getName()))")
        print("Club Name: \(String(describing: viewModel.currentManager?.activeBusiness?.name))")
        
        guard let club_Name = viewModel.currentManager?.activeBusiness?.name else {
            return [] // Return an empty array if the user is not a Manager
        }
        return events.filter { $0.clubName == club_Name }
    }
}


struct TonightUserEventsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var selectedEvent: Event? // To store the selected event for editing
    var events: [Event]

    var body: some View {
        if events.isEmpty {
            Text("No Events Tonight")
                .foregroundStyle(.primary)
                .padding()
            Spacer()
        } else {
            ScrollView {
                ForEach(events) { event in
                    Button(action: {
                        selectedEvent = event // Set the selected event
                    }) {
                        Event_Cell(event: event)
                            .padding(.bottom, 10)
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in // Present the edit view as a sheet
                EventsEditView(
                    event: event,
                    clubName: event.clubName ?? "",
                    clubImageURL: event.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
    }
}

struct UpcomingUserEventsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var selectedEvent: Event? // To store the selected event for editing
    var events: [Event]

    var body: some View {
        if events.isEmpty {
            Text("No Upcoming Events")
                .foregroundStyle(.primary)
                .padding()
            Spacer()
        } else {
            ScrollView {
                ForEach(events) { event in
                    Button(action: {
                        selectedEvent = event // Set the selected event
                    }) {
                        Event_Cell(event: event)
                            .padding(.bottom, 10)
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in // Present the edit view as a sheet
                EventsEditView(
                    event: event,
                    clubName: event.clubName ?? "",
                    clubImageURL: event.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshClubs()
                    }
                )
            }
        }
    }
}

struct EventsView_display: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(club_firebase_handler())
            .environmentObject(log_in_view_model())
    }
}

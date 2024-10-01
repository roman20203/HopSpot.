//
//  frat_user_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-26.
//


import SwiftUI
import Firebase

struct frat_user_view: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var selectedSection: String = "Tonight"
    

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
                TonightUserFratEventsView(events: filteredFratEvents(for: clubHandler.currentFratEvents))
            } else {
                UpcomingUserFratEventsView(events: filteredFratEvents(for: clubHandler.upcomingFratEvents))
            }
        }
        .navigationTitle("Frat Events")
        .padding()
    }
    
    private func filteredFratEvents(for events: [Event]) -> [Event] {
        // Ensure the user has a fraternity with a name
        print("User: \(String(describing: viewModel.currentUser?.getName()))")
        print("Fraternity Name: \(String(describing: viewModel.currentUser?.frat?.name))")
        
        guard let fraternityName = viewModel.currentUser?.frat?.name else {
            return [] // Return an empty array if the user is not in a fraternity
        }
        return events.filter { $0.clubName == fraternityName }
    }
}


struct TonightUserFratEventsView: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var selectedEvent: Event? // To store the selected event for editing
    var events: [Event]

    var body: some View {
        if events.isEmpty {
            Text("No Frat Events Tonight")
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
                frat_event_edit_view(
                    event: event,
                    clubName: event.clubName ?? "",
                    clubImageURL: event.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshFrats()
                    }
                )
            }
        }
    }
}

struct UpcomingUserFratEventsView: View {
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
                frat_event_edit_view(
                    event: event,
                    clubName: event.clubName ?? "",
                    clubImageURL: event.clubImageURL ?? "",
                    onSave: {
                        clubHandler.refreshFrats()
                    }
                )
            }
        }
    }
}


struct frat_user_view_display: PreviewProvider {
    static var previews: some View {
        frat_user_view()
            .environmentObject(club_firebase_handler())
    }
}

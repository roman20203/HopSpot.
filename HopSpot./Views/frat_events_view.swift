//
//  frat_events_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-15.
//
import SwiftUI
import Firebase

struct frat_events_view: View {
    @EnvironmentObject var clubHandler: club_firebase_handler
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
            .padding(.horizontal, 10) // Adjust padding to ensure it fits well on the screen
            
            Spacer()
            
            if selectedSection == "Tonight" {
                TonightFratEventsView(events: clubHandler.currentFratEvents)
            } else {
                UpcomingFratEventsView(events: clubHandler.upcomingFratEvents)
            }
        }
        .navigationTitle("Frat Events")
        .padding() // Padding for the whole view
    }
}

struct TonightFratEventsView: View {
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
                    Event_Cell(event: event)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}

struct UpcomingFratEventsView: View {
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
                    Event_Cell(event: event)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}

struct frat_events_view_display: PreviewProvider {
    static var previews: some View {
        frat_events_view()
            .environmentObject(club_firebase_handler())
    }
}

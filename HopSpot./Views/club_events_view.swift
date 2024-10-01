//
//  club_events_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-15.
//

import SwiftUI
import Firebase


struct club_events_view: View {
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
            Spacer()

            if selectedSection == "Tonight" {
                TonightEventsView(events: clubHandler.currentEvents)
            } else {
                UpcomingEventsView(events: clubHandler.upcomingEvents)
            }
        }
        .navigationTitle("Club and Club Events")
        .padding() // Padding for the whole view
    }
}


struct TonightEventsView: View {
    var events: [Event]

    var body: some View {
        if events.isEmpty {
            Text("No Events Tonight")
                .foregroundStyle(.primary)
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

struct UpcomingEventsView: View {
    var events: [Event]

    var body: some View {
        if events.isEmpty {
            Text("No Upcoming Events")
                .foregroundStyle(.primary)
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

struct club_events_view_display: PreviewProvider {
    static var previews: some View {
        club_events_view()
            .environmentObject(club_firebase_handler())
    }
}

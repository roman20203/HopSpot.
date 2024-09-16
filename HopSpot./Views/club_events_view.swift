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
        .navigationTitle("Club Events")
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
            ForEach(events) { event in
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 10) {
                        // Club image and name
                        HStack(alignment: .top, spacing: 10) {
                            image_view(imagePath: event.clubImageURL ?? "placeholder_image_url")
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            // Club Name
                            Text(event.clubName ?? "Unknown Club")
                                .font(.headline)
                                .padding(.top, 18)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        
                        // Display the event title
                        Text(event.title)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .bold()
                        
                        // Display the description
                        Text(event.description)
                            .font(.body)
                            .foregroundStyle(.primary)

                        // Display event start and end date/time
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Start: \(event.formattedStartDateTime())")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("End: \(event.formattedEndDateTime())")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        
                        // Display link if available
                        if let link = event.link, !link.isEmpty {
                            Link("View Tickets", destination: URL(string: link)!)
                                .font(.body)
                                .foregroundColor(AppColor.color)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColor.color, lineWidth: 2)
                    )
                    .shadow(color: AppColor.color.opacity(0.5), radius: 4, x: 0, y: 2)
                    .frame(width: geometry.size.width - 32, alignment: .leading)
                    .padding(.horizontal, 20)
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
            ForEach(events) { event in
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 10) {
                        // Club image and name
                        HStack(alignment: .top, spacing: 10) {
                            image_view(imagePath: event.clubImageURL ?? "placeholder_image_url")
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            // Club Name
                            Text(event.clubName ?? "Unknown Club")
                                .font(.headline)
                                .padding(.top, 18)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        
                        // Display the event title
                        Text(event.title)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .bold()
                        
                        // Display the description
                        Text(event.description)
                            .font(.body)
                            .foregroundStyle(.primary)

                        // Display event start and end date/time
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Start: \(event.formattedStartDateTime())")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("End: \(event.formattedEndDateTime())")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        
                        // Display link if available
                        if let link = event.link, !link.isEmpty {
                            Link("View Tickets", destination: URL(string: link)!)
                                .font(.body)
                                .foregroundColor(AppColor.color)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColor.color, lineWidth: 2)
                    )
                    .shadow(color: AppColor.color.opacity(0.5), radius: 4, x: 0, y: 2)
                    .frame(width: geometry.size.width - 32, alignment: .leading)
                    .padding(.horizontal, 20)
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

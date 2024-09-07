//
//  EventsView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//


import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct EventsView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var events: [Event] = []
    @State private var showCreateView = false
    @State private var editEvent: Event?

    var body: some View {
        NavigationStack {
            VStack {
                Text("Events")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.primary) // Adapt to light and dark mode
                    .padding(.top, 20)

                if events.isEmpty {
                    Text("No events available.")
                        .font(.subheadline)
                        .foregroundColor(Color.secondary) // Adapt to light and dark mode
                        .padding()
                }

                List {
                    ForEach(events) { event in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                    .foregroundColor(Color.primary) // Adapt to light and dark mode

                                Text(event.description)
                                    .font(.subheadline)
                                    .foregroundColor(Color.primary) // Adapt to light and dark mode

                                Text("Start: \(event.formattedStartDateTime())")
                                    .font(.subheadline)
                                    .foregroundColor(Color.primary) // Adapt to light and dark mode

                                Text("End: \(event.formattedEndDateTime())")
                                    .font(.subheadline)
                                    .foregroundColor(Color.primary) // Adapt to light and dark mode

                                if event.endDate < Date() {
                                    Text("Ended")
                                        .font(.subheadline)
                                        .foregroundColor(.red) // Red for expired events
                                }

                                if let link = event.link, !link.isEmpty {
                                    Link("View Details", destination: URL(string: link)!)
                                        .font(.subheadline)
                                        .foregroundColor(AppColor.color) // Custom color
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground).opacity(0.8)) // Adapt to light and dark mode
                        .cornerRadius(8)
                        .onTapGesture {
                            editEvent = event
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .task {
                    await loadEvents()
                }
                Spacer()
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea()) // Adapt to light and dark mode
            .navigationTitle("Events")
            .sheet(isPresented: $showCreateView) {
                EventsCreateView(clubName: viewModel.currentManager?.activeBusiness?.name ?? "Unknown Club",
                                clubImageURL: viewModel.currentManager?.activeBusiness?.imageURL ?? "placeholder_image_url") {
                    Task {
                        await loadEvents()
                    }
                }
            }
            .sheet(item: $editEvent) { event in
                EventsEditView(event: Binding(
                    get: { event },
                    set: { editEvent = $0 }
                )) {
                    Task {
                        await loadEvents()
                    }
                }
            }
            .overlay(
                Button(action: {
                    showCreateView = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .background(Color(UIColor.systemBackground).opacity(0.7)) // Adapt to light and dark mode
                        .clipShape(Circle())
                        .foregroundColor(AppColor.color) // Custom color
                        .padding()
                }
                .padding(),
                alignment: .bottomTrailing
            )
        }
    }

    private func loadEvents() async {
        guard let clubId = viewModel.currentManager?.activeBusiness?.club_id else {
            print("DEBUG: No club ID found")
            return
        }
        
        do {
            let eventsSnapshot = try await Firestore.firestore().collection("Clubs").document(clubId).collection("Events").getDocuments()
            let loadedEvents = eventsSnapshot.documents.compactMap { try? $0.data(as: Event.self) }
            events = loadedEvents.sorted { $0.startDate < $1.startDate }
        } catch {
            print("DEBUG: Failed to load events with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(log_in_view_model())
}

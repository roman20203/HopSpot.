
//  club_details_template.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-01.
//

import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestoreSwift



struct club_details_template: View {
    let club: Club
    
    @EnvironmentObject var viewModel: log_in_view_model
    @EnvironmentObject var userLocation: UserLocation
    @State private var showRatingView = false
    @State private var hasSubmittedRating = false
    @State private var promotions: [Promotion] = []
    
    @State private var lineReports: [Club.LineReport] = []
    @State private var selectedLineLengthOption: String = ""
    @State private var reportSuccess: Bool = false
    @State private var isReportingAllowed: Bool = true
    
    let distanceThreshold: Double = 30.0 // in Meters

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // Club Image
                    image_view(imagePath: club.imageURL)
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.3)
                        .cornerRadius(15)
                        .clipped()
                        .shadow(radius: 10)
                    
                    // Club Name and Rating Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(club.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<Int(floor(club.rating)), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.yellow)
                            }
                            if club.rating.truncatingRemainder(dividingBy: 1) != 0 {
                                Image(systemName: "star.leadinghalf.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.yellow)
                            }
                            Text("(\(club.reviewCount))")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description Section
                    Text(club.description)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    
                    // Address Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Address")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(club.address)
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)

                    // Busyness Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Busyness")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(busynessDescription(for: mostCommonLineLength(from: lineReports)))
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)

                    // Optional: Distance from user (if userLocation is available)
                    if let userLocation = userLocation.userLocation {
                        let distanceInfo = club.distance(userLocation: userLocation)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Distance")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(String(format: "%.1f km | Approx. Time: %.0f mins", distanceInfo.distanceKm, distanceInfo.estimatedMinutes))
                                .font(.body)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                    // Line Report Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Report Line Length")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 20)
                        
                        Picker("Select Line Length", selection: $selectedLineLengthOption) {
                            Text("Walk in").tag("Walk in")
                            Text("10-20 minutes").tag("10-20 minutes")
                            Text("20-40 minutes").tag("20-40 minutes")
                            Text("40-60 minutes").tag("40-60 minutes")
                            Text("60+ minutes").tag("60+ minutes")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.gray.opacity(1.0))
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        
                        Button(action: {
                            reportLineLength()
                        }) {
                            Text("Submit Report")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 120, height: 20)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(selectedLineLengthOption.isEmpty || !isReportingAllowed)
                        .opacity(selectedLineLengthOption.isEmpty || !isReportingAllowed ? 0.5 : 1.0)
                        
                        if reportSuccess {
                            Text("Report submitted successfully!")
                                .foregroundStyle(.green)
                                .padding(.horizontal)
                        }  else if !selectedLineLengthOption.isEmpty && !isWithinProximity() {
                            Text("You are not close enough to report")
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }else if !isReportingAllowed && !selectedLineLengthOption.isEmpty {
                            Text("Please wait before submitting another report.")
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    
                        // Recent Line Reports
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Reports")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            if lineReports.isEmpty {
                                Text("No reports available.")
                                    .font(.body)
                                    .foregroundStyle(.white)
                            } else {
                                ForEach(lineReports.prefix(3)) { report in
                                    HStack {
                                        Text("Length: \(report.lineLengthOption)")
                                            .font(.body)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("Reported at: \(report.timestamp, style: .time)")
                                            .font(.body)
                                            .foregroundStyle(.white)
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Actions Section
                    HStack(spacing: 5) {
                        // Star rating
                        Button(action: {
                            showRatingView = true
                        }) {
                            Text(hasSubmittedRating ? "Done!" : "Rate Me")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 90, height: 10)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        //.padding(.horizontal)
                        .padding(.top, 10)
                        .disabled(hasSubmittedRating)
                        .sheet(isPresented: $showRatingView) {
                            if let currentUser = viewModel.currentUser {
                                StarRatingTemplate(isPresented: $showRatingView, hasSubmittedRating: $hasSubmittedRating,
                                                   club: club, user: currentUser)
                            } else {
                                Text("User not logged in")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Promotions Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Promotions")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 20)
                        
                        // Fetch promotions from the club object
                        let sortedPromotions = club.promotions.sorted { $0.startDate < $1.startDate }
                        
                        if sortedPromotions.isEmpty {
                            Text("No promotions yet")
                                .font(.body)
                                .foregroundStyle(.white)
                        } else {
                            ScrollView{
                                ForEach(sortedPromotions) { promotion in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Promotion_Cell(promotion: promotion)
                                    }
                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                    
                    // Events Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Events")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 20)
                        
                        // Fetch events from the club object
                        let sortedEvents = club.events.sorted { $0.startDate < $1.startDate }
                        
                        if sortedEvents.isEmpty {
                            Text("No Events yet")
                                .font(.body)
                                .foregroundStyle(.white)
                        } else {
                            ScrollView{
                                ForEach(sortedEvents) { event in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Event_Cell(event:event)
                                    }
                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .onAppear {
                loadLineReports() // Load line reports when the view appears
            }
        }
    }
    /*
    private func isWithinProximity() -> Bool {
        guard let userLocation = userLocation.userLocation else { return false }
        let distance = Userlocation.distaance
        return distance. <= distanceThreshold
    }
     */
    
    private func isWithinProximity() -> Bool {
        guard let userLocation = userLocation.userLocation else { return false }
        
        let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
        let distance = userLocation.distance(from: clubLocation)
           
        return distance <= distanceThreshold // 30 meters
    }
    
    private func mostCommonLineLength(from reports: [Club.LineReport]) -> String {
        let frequency = reports.reduce(into: [String: Int]()) { counts, report in
            counts[report.lineLengthOption, default: 0] += 1
        }
        return frequency.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }

    private func busynessDescription(for lineLength: String) -> String {
        switch lineLength {
        case "Walk in":
            return "The club is not busy. Feel free to walk in!"
        case "10-20 minutes":
            return "The club is moderately busy. Expect a short wait."
        case "20-40 minutes":
            return "The club is busy. Expect a longer wait."
        case "40-60 minutes":
            return "The club is very busy. Plan accordingly."
        case "60+ minutes":
            return "The club is extremely busy"
        default:
            return "No Recent Data."
        }
    }

    private func reportLineLength() {
        if !isWithinProximity(){
            isReportingAllowed = false
            return
        }else{
            isReportingAllowed = true
        }

        club.reportLineLength(option: selectedLineLengthOption, user: viewModel.currentUser) { success in
            if success {
                reportSuccess = true
                isReportingAllowed = false
                
                // Clear selection after reporting
                selectedLineLengthOption = ""
                
                // Reset reporting state after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) { // 60 seconds cooldown
                    isReportingAllowed = true
                }
            } else {
                reportSuccess = false
            }
        }
    }


    private func loadLineReports() {
        Task {
            lineReports = await club.loadLineReports()
        }
    }
}


struct ClubDetailsTemplate_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClub = Club(
            id: "1",
            name: "Sample Club",
            address: "123 Main St",
            rating: 4.5,
            reviewCount: 0,
            description: "A great place to have fun.",
            imageURL: "path/to/image.jpg",
            latitude: 0.0,
            longitude: 0.0,
            busyness: 60,
            website: "www.blah.com",
            city: "Waterloo",
            promotions: [],
            events:[]
        )
        club_details_template(club: sampleClub)
            .environmentObject(UserLocation())
            .environmentObject(log_in_view_model())
    }
}

// Testing Coordinates 43.4738, -80.5275

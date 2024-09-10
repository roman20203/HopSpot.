
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
    @State private var showReviewView = false
    @State private var hasSubmittedRating = false
    @State private var promotions: [Promotion] = []
    
    @State private var lineReports: [Club.LineReport] = []
    @State private var selectedLineLengthOption: String = ""
    @State private var reportSuccess: Bool = false
    @State private var lastReportTime: Date? = nil
    @State private var isReportingAllowed: Bool = true
    
    
    let distanceThreshold: Double = 30.0 //in Meters

    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // Club Image
                    image_view(imagePath: club.imageURL)
                        .frame(height: geometry.size.height * 0.3) // Adjust height relative to screen
                        .cornerRadius(15)
                        .clipped()
                        .shadow(radius: 10)
                    
                    // Club Name and Rating Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(club.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<Int(floor(club.rating)), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.yellow)
                            }
                            if club.rating.truncatingRemainder(dividingBy: 1) != 0 {
                                Image(systemName: "star.leadinghalf.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.yellow)
                            }
                            Text("(\(club.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description Section
                    Text(club.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    
                    // Address Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Address")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(club.address)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    // Busyness Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Business")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(busynessDescription(for: club.busyness))
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    // Optional: Distance from user (if userLocation is available)
                    if let userLocation = userLocation.userLocation {
                        let distanceInfo = club.distance(userLocation: userLocation)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Distance")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(String(format: "%.1f km | Approx. Time: %.0f mins", distanceInfo.distanceKm, distanceInfo.estimatedMinutes))
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Promotions Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Promotions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Fetch promotions from the club object
                        let sortedPromotions = club.promotions.sorted { $0.startDate < $1.startDate }
                        
                        if sortedPromotions.isEmpty {
                            Text("No current promotions")
                                .font(.body)
                                .foregroundColor(.white)
                        } else {
                            ForEach(sortedPromotions) { promotion in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(promotion.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(promotion.description)
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Text("Start: \(promotion.formattedStartDateTime())")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    Text("End: \(promotion.formattedEndDateTime())")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    if let link = promotion.link, !link.isEmpty {
                                        Link("View Tickets", destination: URL(string: link)!)
                                            .font(.body)
                                            .foregroundColor(AppColor.color)
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
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Line Report Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Report Line Length")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Picker("Select Line Length", selection: $selectedLineLengthOption) {
                            Text("Walk in").tag("Walk in")
                            Text("10-20 minutes").foregroundColor(.white).tag("10-20 minutes")
                            Text("20-40 minutes").foregroundColor(.white).tag("20-40 minutes")
                            Text("40-60 minutes").foregroundColor(.white).tag("40-60 minutes")
                            Text("60+ minutes").foregroundColor(.white).tag("60+ minutes")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.gray.opacity(1.0))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        
                        
                        
                        Button(action: {
                            reportLineLength()
                        }) {
                            Text("Submit Report")
                                .font(.headline)
                                .foregroundColor(.white)
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
                                .foregroundColor(.green)
                                .padding(.horizontal)
                        }else if(!isReportingAllowed && !selectedLineLengthOption.isEmpty){
                            Text("Please wait before submitting another report.")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }else if(!selectedLineLengthOption.isEmpty && !isWithinProximity()){
                            Text("You are not close enough to report")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                            }
                                    
                    
                        // Recent Line Reports
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Reports")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if lineReports.isEmpty {
                                Text("No reports available.")
                                    .font(.body)
                                    .foregroundColor(.white)
                            } else {
                                ForEach(lineReports.prefix(3)) { report in
                                    HStack {
                                        Text("Length: \(report.lineLengthOption)")
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Reported at: \(report.timestamp, style: .time)")
                                            .font(.body)
                                            .foregroundColor(.white)
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
                                .foregroundColor(.white)
                                .frame(width: 90, height: 10)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
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
                        
                        /* Written review
                        Button(action: {
                            showReviewView = true
                        }) {
                            Text("Review")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 90, height: 10)
                                .padding()
                                .background(AppColor.color)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                         */
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
                .cornerRadius(15)
                .shadow(radius: 10)
                .frame(width: geometry.size.width)
            }
            .navigationTitle(club.name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadInitialData()
            }
        }
    }
    private func isWithinProximity() -> Bool {
        guard let userLocation = userLocation.userLocation else { return false }
        
        let clubLocation = CLLocation(latitude: club.latitude, longitude: club.longitude)
        let distance = userLocation.distance(from: clubLocation)
        
        return distance <= distanceThreshold // 30 meters
    }
    
    private func busynessDescription(for busyness: busynessType) -> String {
        switch busyness {
        case .Empty:
            return "Empty"
        case .Light:
            return "Light"
        case .Moderate:
            return "Moderate"
        case .Busy:
            return "Busy"
        case .VeryBusy:
            return "Very Busy"
        }
    }
    
    private func loadInitialData() async {
        async let lineReportsTask: () = loadLineReports()
        _ = await (lineReportsTask)

    }

    
    private func loadLineReports() async {
        let clubId = club.id
        

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        do {
            let reportsSnapshot = try await Firestore.firestore()
                .collection("Clubs")
                .document(clubId)
                .collection("lineReports")
                .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay) // Filter reports from today
                .whereField("timestamp", isLessThan: endOfDay) // Ensure the report is within today
                .order(by: "timestamp", descending: true) // Sort by timestamp in descending order
                .limit(to: 3) // Limit to the 3 most recent reports
                .getDocuments()
             
            lineReports = reportsSnapshot.documents.compactMap { document in
                var report = try? document.data(as: Club.LineReport.self)
                report?.id = document.documentID
                return report
            }
        } catch {
            print("DEBUG: Error fetching line reports: \(error.localizedDescription)")
        }
    }

    private func reportLineLength() {
        guard let user = viewModel.currentUser else { return }
        
        if !isWithinProximity() {
            print("DEBUG: User is not within 30 meters of the club.")
            return
        }
        
        guard isReportingAllowed else { return }
        
        let currentTime = Date()
        if let lastTime = lastReportTime, currentTime.timeIntervalSince(lastTime) < 60 {
            return
        }
        
        lastReportTime = currentTime
        isReportingAllowed = false
        
        let clubId = club.id
        let reportRef = Firestore.firestore().collection("Clubs").document(clubId).collection("lineReports").document()
        let reportId = reportRef.documentID
        
        let report = Club.LineReport(
            id: reportId,
            lineLengthOption: selectedLineLengthOption,
            timestamp: currentTime
        )
        
        do {
            try reportRef.setData(from: report)
            reportSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                isReportingAllowed = true
            }
        } catch {
            print("DEBUG: Error submitting line report: \(error.localizedDescription)")
            isReportingAllowed = true
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
            busyness: 90,
            website: "www.blah.com",
            city: "Waterloo",
            promotions: []
        )
        club_details_template(club: sampleClub)
            .environmentObject(UserLocation())
            .environmentObject(log_in_view_model())
    }
}

// Testing Coordinates 43.4738, -80.5275

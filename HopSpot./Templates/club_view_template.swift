//
//  club_view_template.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-22.
//
import SwiftUI

struct club_view_template: View {
    let club: Club
    
    @State private var lineReports: [Club.LineReport] = []
    @State private var busynessColor: Color = Color.black
    @State private var busynessDescriptionText: String = "No Recent Data."

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            image_view(imagePath: club.imageURL)
                .frame(width: 350, height: 170)
                .cornerRadius(10)
                .clipped()
            
            VStack(alignment: .leading) {
                HStack {
                    Text(club.name)
                        .foregroundColor(.black)
                        .font(.headline)
                    
                    // Star rating
                    HStack(spacing: 2) {
                        ForEach(0..<Int(floor(club.rating)), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .foregroundColor(.yellow)
                        }
                        if club.rating.truncatingRemainder(dividingBy: 1) != 0 {
                            Image(systemName: "star.leadinghalf.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .foregroundColor(.yellow)
                        }
                        Text("(\(club.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 1)
                
                Text(club.description)
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.bottom, 1)
                
                // Busyness Section
                HStack {
                    HStack{
                        Text("Busyness:")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                                        
                        Text(busynessDescriptionText) // Use busynessDescriptionText for text
                            .font(.subheadline)
                            .foregroundStyle(busynessColor) // Use busynessColor for text color
                    }
                    Spacer()
                    Text(">")
                        .font(.body)
                        .foregroundStyle(AppColor.color)
                    
                }
            }
            .padding(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
        }
        .frame(width: 350, height: 170)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .onAppear {
            loadLineReports()
        }
    }
    
    private func updateBusynessDescription() {
        let recentReports = lineReports.filter { isLessThanThirtyMinutesOld($0.timestamp) }
        
        if let mostRecentReport = recentReports.max(by: { $0.timestamp < $1.timestamp }) {
            (busynessDescriptionText, busynessColor) = busynessDescription(for: mostRecentReport.lineLengthOption)
        } else {
            // No recent reports found
            busynessDescriptionText = "No Recent Data."
            busynessColor = Color.black
        }
    }
    
    private func busynessDescription(for lineLength: String) -> (String, Color) {
        switch lineLength {
        case "Walk in":
            return ("Feel free to walk in!", Color.green)
        case "10-20 minutes":
            return ("Expect a short wait.", Color.green)
        case "20-40 minutes":
            return ("Expect a longer wait.", Color(red: 185/255, green: 185/255, blue: 7/255, opacity: 255/255))
        case "40-60 minutes":
            return ("Very busy.", Color(red: 185/255, green: 185/255, blue: 7/255, opacity: 255/255))
        case "60+ minutes":
            return ("Extremely busy", Color.red)
        default:
            return ("No Recent Data.", Color.black)
        }
    }
    
    private func mostCommonLineLength(from reports: [Club.LineReport]) -> String {
        let frequency = reports.reduce(into: [String: Int]()) { counts, report in
            counts[report.lineLengthOption, default: 0] += 1
        }
        return frequency.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private func isLessThanThirtyMinutesOld(_ timestamp: Date) -> Bool {
        let thirtyMinutesAgo = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
        return timestamp >= thirtyMinutesAgo
    }
    
    private func loadLineReports() {
        Task {
            let reports = await club.loadLineReports()
            DispatchQueue.main.async {
                lineReports = reports
                updateBusynessDescription() // Update busyness description and color after loading reports
            }
        }
    }
}


struct club_view_template_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClub = Club(
            id: "1",
            name: "Sample Club",
            address: "123 Club Lane",
            rating: 2.5,
            reviewCount: 0,
            description: "This is a sample club description. It's a great place to hang out and enjoy some music.",
            imageURL: "rabbit_logo",
            latitude: 37.7749,
            longitude: -122.4194,
            busyness: 60,
            website: "https://www.sampleclub.com/",
            city: "Waterloo, ON"
        )
        club_view_template(club: sampleClub)
    }
}

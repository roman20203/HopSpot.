//
//  Event_Cell.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-17.
//
import SwiftUI

struct Event_Cell: View {
    var event: Event
    @State private var isDescriptionExpanded: Bool = false
    
    var body: some View {
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
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Display the event title
            Text(event.title)
                .font(.title3)
                .foregroundStyle(.white)
                .bold()
            
            // Display the description with "See More" option
            VStack(alignment: .leading, spacing: 3) {
                Text(event.description)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(isDescriptionExpanded ? nil : 3)
                    .truncationMode(.tail)
                
                Button(action: {
                    withAnimation {
                        isDescriptionExpanded.toggle()
                    }
                }) {
                    Text(isDescriptionExpanded ? "See Less" : "See More")
                        .font(.body)
                        .foregroundColor(AppColor.color)
                        .padding(.top, 2)
                }
            }
            
            // Display event start and end date/time
            VStack(alignment: .leading, spacing: 3) {
                Text("Start: \(event.formattedStartDateTime())")
                    .font(.body)
                    .foregroundStyle(.white)
                Text("End: \(event.formattedEndDateTime())")
                    .font(.body)
                    .foregroundStyle(.white)
            }
            
            // Display link if available
            if let link = event.link, !link.isEmpty {
                Link("View Tickets", destination: URL(string: link)!)
                    .font(.body)
                    .foregroundColor(AppColor.color)
                    .padding(.top, 2)
            }
        }
        .padding() // Padding inside the cell
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.color, lineWidth: 2)
        )
        .shadow(color: AppColor.color.opacity(0.5), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity) // Ensure the cell stretches to full width
        .padding(.horizontal, 10) // Adjust padding as needed
    }
}


//
//  Promotion_Cell.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-23.
//
import SwiftUI

struct Promotion_Cell: View {
    var promotion: Promotion
    @State private var isDescriptionExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Club image and name
            HStack(alignment: .top, spacing: 10) {
                image_view(imagePath: promotion.clubImageURL ?? "placeholder_image_url")
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                // Club Name
                Text(promotion.clubName ?? "Unknown Club")
                    .font(.headline)
                    .padding(.top, 18)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Display the promotion title
            Text(promotion.title)
                .font(.title3)
                .foregroundStyle(.white)
                .bold()
            
            // Display the description with "See More" option
            VStack(alignment: .leading, spacing: 3) {
                Text(promotion.description)
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
            
            // Display promotion start and end date/time
            VStack(alignment: .leading, spacing: 3) {
                Text("Start: \(promotion.formattedStartDateTime())")
                    .font(.body)
                    .foregroundStyle(.white)
                Text("End: \(promotion.formattedEndDateTime())")
                    .font(.body)
                    .foregroundStyle(.white)
            }
            
            // Display link if available
            if let link = promotion.link, !link.isEmpty {
                Link("View Details", destination: URL(string: link)!)
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
        //.padding(.horizontal, 10) // Adjust padding as needed
    }
}

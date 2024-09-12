//
//  notification_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import SwiftUI
import Firebase

struct user_promotion_view: View {
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
                TonightPromotionsView(promotions: clubHandler.currentPromotions)
            } else {
                UpcomingPromotionsView(promotions: clubHandler.upcomingPromotions)
            }
        }
        .navigationTitle("Promotions")
        }
    }

struct TonightPromotionsView: View {
    var promotions: [Promotion]

    var body: some View {
        if promotions.isEmpty{
            Text("No Promotions Tonight")
            Spacer()
        }else{
            ForEach(promotions, id: \.id) { promotion in
                GeometryReader { geometry in
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
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        // Display the promotion title
                        Text(promotion.title)
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                        
                        // Display the description
                        Text(promotion.description)
                            .font(.body)
                            .foregroundColor(.white)

                        
                        // Display promotion start and end date/time
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Start: \(promotion.formattedStartDateTime())")
                                .font(.body)
                                .foregroundColor(.white)
                            Text("End: \(promotion.formattedEndDateTime())")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        
                        // Display link if available
                        if let link = promotion.link, !link.isEmpty {
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

struct UpcomingPromotionsView: View {
    var promotions: [Promotion]

    var body: some View {
        if promotions.isEmpty{
            Text("No Upcoming Promotions")
            Spacer()
        }else{
            ForEach(promotions, id: \.id) { promotion in
                GeometryReader { geometry in
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
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        // Display the promotion title
                        Text(promotion.title)
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                        
                        // Display the description
                        Text(promotion.description)
                            .font(.body)
                            .foregroundColor(.white)

                        
                        // Display promotion start and end date/time
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Start: \(promotion.formattedStartDateTime())")
                                .font(.body)
                                .foregroundColor(.white)
                            Text("End: \(promotion.formattedEndDateTime())")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        
                        // Display link if available
                        if let link = promotion.link, !link.isEmpty {
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

struct user_promotion_view_display: PreviewProvider {
    static var previews: some View {
        user_promotion_view()
            .environmentObject(club_firebase_handler())
    }
}

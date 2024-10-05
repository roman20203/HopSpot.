//
//  user_promotion_view_view.swift
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
        .padding()
        .background(Color(.systemBackground))
        }
    }

struct TonightPromotionsView: View {
    var promotions: [Promotion]
    

    var body: some View {
        let currentPromotions = promotions.filter { isCurrentPromotion($0) }
        
        if currentPromotions.isEmpty{
            Text("No Promotions Tonight")
            Spacer()
        }else{
            ScrollView {
                ForEach(currentPromotions) { promotion in
                    Promotion_Cell(promotion: promotion)
                        .padding(.bottom, 10)
                }
            }
        }
    }
    

    func isCurrentPromotion(_ promotion: Promotion) -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current

        // Combine date and time for the start and end of the promotion
        let promotionStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: promotion.startTime),
                                               minute: calendar.component(.minute, from: promotion.startTime),
                                               second: 0,
                                               of: promotion.startDate)

        let promotionEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: promotion.endTime),
                                             minute: calendar.component(.minute, from: promotion.endTime),
                                             second: 0,
                                             of: promotion.endDate)

        // Debugging: Print promotion title, start time, and end time
        print("Promotion \(String(describing: promotion.title)) - Start Time: \(String(describing: promotionStartTime)), End Time: \(String(describing: promotionEndTime))")

        // Check if the promotion is either:
        // 1. Ongoing (start time <= current time <= end time)
        // 2. Starting today (regardless of the current time of day)
        if let startTime = promotionStartTime, let endTime = promotionEndTime {
            // Check if promotion is ongoing
            if currentDate >= startTime && currentDate <= endTime {
                return true
            }
            
            // Check if promotion starts today (but hasn't yet started)
            if calendar.isDateInToday(promotion.startDate) && currentDate < startTime {
                return true
            }
        }
        
        return false
    }

     

     

}

struct UpcomingPromotionsView: View {
    var promotions: [Promotion]

    var body: some View {
        if promotions.isEmpty{
            Text("No Upcoming Promotions")
            Spacer()
        }else{
            ScrollView {
                ForEach(promotions) { promotion in
                    Promotion_Cell(promotion: promotion)
                        .padding(.bottom, 10)
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

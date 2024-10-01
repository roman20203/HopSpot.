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

        // Check if the promotion is ongoing or starts later today
        if (promotion.startDate <= currentDate && promotion.endDate >= currentDate) ||
           (calendar.isDateInToday(promotion.startDate) && promotion.startTime > currentDate) ||
           (promotion.startDate == currentDate && promotion.startTime > currentDate) {
            
            // Get the start and end times as Date objects
            let promotionStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: promotion.startTime),
                                                    minute: calendar.component(.minute, from: promotion.startTime),
                                                    second: 0,
                                                    of: promotion.startDate)
            
            let promotionEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: promotion.endTime),
                                                  minute: calendar.component(.minute, from: promotion.endTime),
                                                  second: 0,
                                                  of: promotion.endDate)

            // Check if current time is between the promotion start and end time
            if let promotionStart = promotionStartTime, let promotionEnd = promotionEndTime {
                return currentDate >= promotionStart && currentDate <= promotionEnd
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

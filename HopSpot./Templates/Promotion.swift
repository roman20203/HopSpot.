//
//  Promotion.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import Foundation
import FirebaseFirestoreSwift

struct Promotion: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var startTime: Date
    var endTime: Date
    var link: String?
    var clubName: String?
    var clubImageURL: String?

    func formattedStartDateTime() -> String {
        return startDate.formattedDateTime()
    }


    func formattedEndDateTime() -> String {
        return endDate.formattedDateTime()
    }
}

extension Date {
    func formattedDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }

    func formattedTime() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: self)
    }
}

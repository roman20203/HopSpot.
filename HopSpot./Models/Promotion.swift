//
//  Promotion.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import Foundation
import FirebaseFirestoreSwift

struct Promotion: Identifiable, Codable {
    var id: String?
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Format the date
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Format the time

        let formattedDate = dateFormatter.string(from: startDate) // Format startDate
        let formattedTime = timeFormatter.string(from: startTime) // Format startTime
        
        return "\(formattedDate) at \(formattedTime)" // Combine date and time
    }

    func formattedEndDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Format the date
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Format the time
        
        let formattedDate = dateFormatter.string(from: endDate) // Format endDate
        let formattedTime = timeFormatter.string(from: endTime) // Format endTime
        
        return "\(formattedDate) at \(formattedTime)" // Combine date and time
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

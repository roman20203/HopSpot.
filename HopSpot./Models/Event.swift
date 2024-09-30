//
//  Event.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Event: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var startTime: Date
    var endTime: Date
    var location: String
    var clubName: String?
    var clubImageURL: String?
    var link: String?


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

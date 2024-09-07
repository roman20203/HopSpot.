//
//  Event.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-09-07.
//

import Foundation
import FirebaseFirestoreSwift

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
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
        return startDate.formattedDateTime()
    }

    func formattedEndDateTime() -> String {
        return endDate.formattedDateTime()
    }
}

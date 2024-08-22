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
    var startTime: Date // Add time component
    var endTime: Date // Add time component
    var link: String? // Optional link for tickets or additional information
}

//
//  location.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-05.
//

import Foundation

enum bcType: String, Codable{
    case Club
    case Bar
}

enum busynessType: String, Codable{
    case Empty
    case Light
    case Moderate
    case Busy
    case VeryBusy
}



struct Club: Codable{
    
    var id: String
    var name: String
    var address: String
    var rating: Double
    var description: String
    var imageURL: String
    var latitude: Double
    var longitude: Double
    var busyness: busynessType
    
    
    init(id:String, name:String , address:String, rating:Double, description: String, imageURL: String, latitude: Double, longitude:Double, busyness:busynessType){
        
        self.id = id
        self.name = name
        self.address = address
        self.rating = rating
        self.description = description
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.busyness = busyness
        
    }
    
    
    mutating func updateRating(rating: Double){
        self.rating = rating
        
    }
    
    mutating func updateBusyness(num: Int){
        if num >= 0 && num < 10 {
            self.busyness = .Empty
        } else if num >= 10 && num < 30 {
            self.busyness = .Moderate
        } else if num >= 30 && num < 60 {
            self.busyness = .Busy
        } else if num >= 60 {
            self.busyness = .VeryBusy
        }
    
    }
    
    
}

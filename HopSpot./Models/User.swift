//
//  user.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-05.
//

import Foundation


enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { self.rawValue } 
}

//Password hashing

struct User:Identifiable, Codable{
    let id: String
    var fullname: String
    let email: String
    var passwordHash: String
    var joined: Date
    var birthdate:Date
    var gender: Gender
    
    
    var friends: [User] = []
    //Type here will need to be changed depending on what we use to identify the bars
    var favoriteClubs: [String] = []
    
    var age: Int {
            getAge(from: birthdate)
        }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let componenets = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: componenets)
        }
        return ""
    }


    static func hashPassword(_ password: String) -> String {
        //implement more complex hashing algorithm
        return String(password.reversed())
    }

    init(fullname: String,id: String, email: String, password: String, joined: Date, birthdate: Date, gender: Gender) {
        self.fullname = fullname
        self.email = email
        self.passwordHash = User.hashPassword(password)
        self.joined = joined
        self.birthdate = birthdate
        self.gender = gender
        self.friends = []
        self.favoriteClubs = []
        self.id = id

    }
    
    func getName() ->String {
        return self.fullname
    }
    
    
    func getEmail() ->String{
        return self.email
    }
    
    private func getAge(from birthdate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([ .year ], from: birthdate, to: now)
        return ageComponents.year ?? 0
    }
    

    mutating func updateName(newName: String) {
        self.fullname = newName
    }
    
    mutating func addFriend(_ friend: User) {
        if !friends.contains(where: { $0.email == friend.email }) {
            friends.append(friend)
        }
    }
    

    mutating func removeFriend(_ friend: User) {
        friends.removeAll { $0.email == friend.email }
    }
    
 
    mutating func addFavoriteClub(_ clubID: String) {
        if !favoriteClubs.contains(clubID) {
            favoriteClubs.append(clubID)
        }
    }
    

    mutating func removeFavoriteClub(_ clubID: String) {
        favoriteClubs.removeAll { $0 == clubID }
    }
    
}




//
//  user.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-05.
//

import Foundation


enum Gender: String, Codable {
    case male
    case female
    case preferNotToSay
}

//Password hashing

struct user:Codable{
    private var name: String
    private var email: String
    var passwordHash: String
    var joined: Date
    var gender: Gender
    
    var friends: [user] = []
    
    //Type here will need to be changed depending on what we use to identify the bars
    var favoriteClubs: [String] = []
    
    
    private static func hashPassword(_ password: String) -> String {
        //implement more complex hashing algorithm
        return String(password.reversed())
    }

    init(name: String, email: String, password: String, joined: Date, gender: Gender) {
        self.name = name
        self.email = email
        self.passwordHash = user.hashPassword(password)
        self.joined = joined
        self.gender = gender

    }
    
    func getName() ->String {
        return self.name
    }
    
    
    func getEmail() ->String{
        return self.email
    }
    

    mutating func updateName(newName: String) {
        self.name = newName
    }
    
    mutating func addFriend(_ friend: user) {
        if !friends.contains(where: { $0.email == friend.email }) {
            friends.append(friend)
        }
    }
    

    mutating func removeFriend(_ friend: user) {
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



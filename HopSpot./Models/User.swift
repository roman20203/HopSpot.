import Foundation

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { self.rawValue }
}

enum UserRole: String, Codable {
    case regularUser = "RegularUser"
    case bouncer = "Bouncer"
    case manager = "Manager"
}

struct User: Identifiable, Codable {
    let id: String
    var fullname: String
    let email: String
    var passwordHash: String
    var joined: Date
    var birthdate: Date
    var gender: Gender
    var role: UserRole
    var fraternityID: String?
    var frat: Fraternity?
    
    var snapchatUsername: String?
    var instagramUsername: String?
    var profileImageUrl: String? // Stores the URL of the user's profile image
    var backgroundImageUrl: String? // Stores the URL of the background image
    var school: String? // Stores the user's school
    
    var friends: [User] = []
    var favoriteClubs: [String] = []
    
    var isFrat: Bool {
        return fraternityID != ""  // Returns true if fraternityID is not nil, otherwise false
    }
    
    var age: Int {
        getAge(from: birthdate)
    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
    static func hashPassword(_ password: String) -> String {
        // Implement more complex hashing algorithm
        return String(password.reversed())
    }

    init(fullname: String, id: String, email: String, password: String, joined: Date, birthdate: Date, gender: Gender, role: UserRole, fraternityID: String? = nil, snapchatUsername: String? = nil, instagramUsername: String? = nil, profileImageUrl: String? = nil, backgroundImageUrl: String? = nil, school: String? = nil) {
        self.fullname = fullname
        self.email = email
        self.passwordHash = User.hashPassword(password)
        self.joined = joined
        self.birthdate = birthdate
        self.gender = gender
        self.id = id
        self.role = role
        self.fraternityID = fraternityID
        self.snapchatUsername = snapchatUsername
        self.instagramUsername = instagramUsername
        self.profileImageUrl = profileImageUrl // Initialize the profile image URL
        self.backgroundImageUrl = backgroundImageUrl // Initialize the background image URL
        self.school = school // Initialize the school
    }

    func getName() -> String {
        return self.fullname
    }
    
    func getEmail() -> String {
        return self.email
    }

    private func getAge(from birthdate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
        return ageComponents.year ?? 0
    }

    mutating func updateName(newName: String) {
        self.fullname = newName
    }
}


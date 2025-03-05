import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var lastLoginDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case lastLoginDate = "last_login_date"
    }
}

// MARK: - User Default Values
extension User {
    static func create(email: String) -> User {
        User(
            id: UUID().uuidString,
            email: email,
            lastLoginDate: Date()
        )
    }
} 

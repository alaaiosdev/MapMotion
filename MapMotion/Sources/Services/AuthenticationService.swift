import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

enum AuthError: Error {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyInUse:
            return "Email is already in use"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol AuthenticationServiceProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() throws
    func getCurrentUser() -> User?
    func getPreviousLogins() async throws -> [String]
}

final class AuthenticationService: AuthenticationServiceProtocol {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    
    private let previousLoginsKey = "previous_logins"
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let user = User.create(email: email)
            
            // Save to local storage
            try await saveUserLocally(user)
            
            // Check if user document exists in Firestore
            let docRef = db.collection("users").document(user.id)
            let docSnapshot = try await docRef.getDocument()
            
            if docSnapshot.exists {
                // Update existing document
                try await updateUserInFirestore(user)
            } else {
                // Create new document
                try await saveUserToFirestore(user)
            }
            
            // Add to previous logins
            addToPreviousLogins(email)
            
            return user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User.create(email: email)
            
            // Save to local storage
            try await saveUserLocally(user)
            
            // Save to Firestore
            try await saveUserToFirestore(user)
            
            // Add to previous logins
            addToPreviousLogins(email)
            
            return user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func getCurrentUser() -> User? {
        guard let currentUser = auth.currentUser else { return nil }
        return User(
            id: currentUser.uid,
            email: currentUser.email ?? "",
            lastLoginDate: Date()
        )
    }
    
    func getPreviousLogins() async throws -> [String] {
        return userDefaults.stringArray(forKey: previousLoginsKey) ?? []
    }
    
    // MARK: - Private Methods
    
    private func saveUserLocally(_ user: User) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: "current_user")
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        try await db.collection("users").document(user.id).setData([
            "email": user.email,
            "last_login_date": user.lastLoginDate
        ])
    }
    
    private func updateUserInFirestore(_ user: User) async throws {
        try await db.collection("users").document(user.id).updateData([
            "last_login_date": user.lastLoginDate
        ])
    }
    
    private func addToPreviousLogins(_ email: String) {
        var previousLogins = userDefaults.stringArray(forKey: previousLoginsKey) ?? []
        if !previousLogins.contains(email) {
            previousLogins.append(email)
            userDefaults.set(previousLogins, forKey: previousLoginsKey)
        }
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let authError = error as NSError
        switch authError.code {
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidEmail.rawValue:
            return .invalidCredentials
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        default:
            return .unknown(error)
        }
    }
} 

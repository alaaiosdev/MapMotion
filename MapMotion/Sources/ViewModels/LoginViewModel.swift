import Foundation
import Combine

enum LoginState: Equatable {
    case idle
    case loading
    case success(User)
    case error(String)

    static func == (lhs: LoginState, rhs: LoginState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let user1), .success(let user2)):
            return user1.id == user2.id
        case (.error(let msg1), .error(let msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var state = LoginState.idle
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    func login() async {
        guard !email.isEmpty && !password.isEmpty else {
            state = .error("Please enter both email and password")
            return
        }
        
        state = .loading
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            state = .success(user)
        } catch {
            if let authError = error as? AuthError {
                state = .error(authError.localizedDescription)
            } else {
                state = .error("An unexpected error occurred")
            }
        }
    }
    
    func signUp() async {
        guard !email.isEmpty && !password.isEmpty else {
            state = .error("Please enter both email and password")
            return
        }
        
        state = .loading
        
        do {
            let user = try await authService.signUp(email: email, password: password)
            state = .success(user)
        } catch {
            if let authError = error as? AuthError {
                state = .error(authError.localizedDescription)
            } else {
                state = .error("An unexpected error occurred")
            }
        }
    }
    
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword() -> Bool {
        return password.count >= 6
    }
} 

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isSignUp = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                    
                    Text("MapMotion")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 20) {
                    // Email field
                    CustomTextField(
                        text: $viewModel.email,
                        placeholder: "Email",
                        systemImage: "envelope.fill"
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    // Password field
                    CustomTextField(
                        text: $viewModel.password,
                        placeholder: "Password",
                        systemImage: "lock.fill",
                        isSecure: true
                    )
                    .textContentType(isSignUp ? .newPassword : .password)
                    
                    // Action Button
                    Button(action: {
                        Task {
                            if isSignUp {
                                await viewModel.signUp()
                            } else {
                                await viewModel.login()
                            }
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                            .opacity(viewModel.validateEmail() && viewModel.validatePassword() ? 1 : 0.7)
                    }
                    .disabled(!viewModel.validateEmail() || !viewModel.validatePassword())
                    
                    // Toggle Sign Up/Login
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            
            // Loading overlay
            if case .loading = viewModel.state {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .onChange(of: viewModel.state) { state in
            if case .success = state {
                isLoggedIn = true
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { if case .error = viewModel.state { return true } else { return false } },
                set: { _ in viewModel.state = .idle }
            ),
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                if case let .error(message) = viewModel.state {
                    Text(message)
                }
            }
        )
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.2))
        )
        .foregroundColor(.white)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
} 

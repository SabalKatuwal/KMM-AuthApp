import SwiftUI
import GoogleSignIn
import Shared

/// Login/Signup View with email and password fields.
struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModelWrapper

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUpMode: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Logo/Header
                        headerSection

                        // Form fields
                        formSection

                        // Action buttons
                        actionButtonsSection

                        // Divider
                        dividerSection

                        // Google Sign-In
                        googleSignInSection

                        // Toggle sign up/login
                        toggleModeSection
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 50)
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🇳🇵")
                .font(.system(size: 60))

            Text(isSignUpMode ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(isSignUpMode ? "Sign up to get started" : "Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.bottom, 20)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // Email field
            CustomTextField(
                placeholder: "Email",
                text: $email,
                isSecure: false,
                icon: "envelope.fill"
            )

            // Password field
            CustomTextField(
                placeholder: "Password",
                text: $password,
                isSecure: true,
                icon: "lock.fill"
            )

            // Confirm password (only for sign up)
            if isSignUpMode {
                CustomTextField(
                    placeholder: "Confirm Password",
                    text: $confirmPassword,
                    isSecure: true,
                    icon: "lock.fill"
                )
            }
        }
    }

    private var actionButtonsSection: some View {
        Button(action: performAction) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                } else {
                    Text(isSignUpMode ? "Sign Up" : "Login")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))

            Text("OR")
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private var googleSignInSection: some View {
        Button(action: performGoogleSignIn) {
            HStack {
                Image(systemName: "g.circle.fill")
                    .foregroundColor(.red)
                Text("Continue with Google")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }

    private var toggleModeSection: some View {
        Button(action: {
            withAnimation {
                isSignUpMode.toggle()
                clearForm()
            }
        }) {
            HStack {
                Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                    .foregroundColor(.white.opacity(0.8))
                Text(isSignUpMode ? "Login" : "Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .font(.subheadline)
        }
        .padding(.top, 10)
    }

    // MARK: - Helper Properties

    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    // MARK: - Actions

    private func performAction() {
        if isSignUpMode {
            viewModel.signUp(email: email, password: password)
        } else {
            viewModel.login(email: email, password: password)
        }
    }

    private func performGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GoogleSignInHelper.shared.signIn(presenting: rootViewController) { result in
            switch result {
            case .success(let tokens):
                viewModel.signInWithGoogle(idToken: tokens.idToken, accessToken: tokens.accessToken)
            case .failure(let error):
                print("Google Sign-In error: \(error.localizedDescription)")
            }
        }
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }
}

// MARK: - Custom Text Field

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(viewModel: AuthViewModelWrapper())
    }
}

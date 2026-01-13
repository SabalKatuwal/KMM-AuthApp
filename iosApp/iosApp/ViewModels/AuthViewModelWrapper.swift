import SwiftUI
import Combine

@MainActor
class AuthViewModelWrapper: ObservableObject {

    @Published var shouldNavigate: Bool = false
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: SwiftAuthUser? = nil
    @Published var errorMessage: String? = nil

    // The auth manager handles all Firebase operations
    private let authManager: FirebaseAuthManager

    init(authManager: FirebaseAuthManager = FirebaseAuthManager.shared) {
        self.authManager = authManager
        startObserving()
    }

    /// Start observing auth state changes.
    private func startObserving() {
        authManager.observeAuthState { [weak self] state in
            DispatchQueue.main.async {
                self?.updateState(from: state)
            }
        }
    }

    /// Update local state from auth state.
    private func updateState(from state: SwiftAuthState) {
        switch state {
        case .loading:
            self.isLoading = true
        case .authenticated(let user):
            print(user)
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = user
        case .unauthenticated:
            self.isLoading = false
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }

    // MARK: - Authentication Actions

    /// Sign up with email and password.
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        authManager.signUpWithEmail(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                print(user)
                self?.isAuthenticated = true
                self?.currentUser = user
            case .error(let message):
                self?.errorMessage = message
            case .loading:
                break
            }
        }
    }

    /// Login with email and password.
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        authManager.loginWithEmail(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                print(user)
                self?.isAuthenticated = true
                self?.currentUser = user
            case .error(let message):
                print("LoginError is: \(message)")
                self?.errorMessage = message
            case .loading:
                break
            }
        }
    }

    /// Sign in with Google credential.
    func signInWithGoogle(idToken: String, accessToken: String? = nil) {
        isLoading = true
        errorMessage = nil

        authManager.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                self?.isAuthenticated = true
                self?.currentUser = user
            case .error(let message):
                self?.errorMessage = message
            case .loading:
                break
            }
        }
    }

    /// Logout the current user.
    func logout() {
        isLoading = true
        errorMessage = nil

        authManager.logout { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.isAuthenticated = false
                self?.currentUser = nil
            case .error(let message):
                self?.errorMessage = message
            case .loading:
                break
            }
        }
    }

    /// Clear error message.
    func clearError() {
        errorMessage = nil
    }
}


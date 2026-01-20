import SwiftUI
import Combine
import Shared

/**
 * Swift wrapper for the shared KMM IOSAuthViewModel.
 *
 * ARCHITECTURE NOTE:
 * - This wraps the shared Kotlin `IOSAuthViewModel` for use in SwiftUI
 * - All business logic is in the shared module, this just bridges to SwiftUI
 * - Uses ObservableObject to integrate with SwiftUI's reactive system
 * - The shared module's Kotlin Flow is converted to Swift callbacks
 */
@MainActor
class AuthViewModelWrapper: ObservableObject {

    /// Published properties for SwiftUI binding
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: AuthUser? = nil
    @Published var errorMessage: String? = nil

    /// The shared KMM ViewModel - all business logic is here
    private let sharedViewModel: IOSAuthViewModel

    /// Subscription to observe auth state changes from shared module
    private var stateObserver: Closeable? = nil

    init() {
        // Create the shared ViewModel from the KMM module
        self.sharedViewModel = IOSAuthViewModelKt.createAuthViewModel()

        // Start observing state changes from the shared module
        startObserving()
    }

    deinit {
        // Clean up subscriptions
        stateObserver?.close()
        sharedViewModel.onCleared()
    }

    /// Start observing auth state changes from the shared KMM module.
    private func startObserving() {
        stateObserver = sharedViewModel.observeUiState { [weak self] state in
            DispatchQueue.main.async {
                self?.updateState(from: state)
            }
        }
    }

    /// Update local published properties from the shared module's state.
    private func updateState(from state: AuthUiState) {
        self.isLoading = state.isLoading
        self.errorMessage = state.errorMessage

        // Handle auth state from shared module
        // AuthState.Authenticated, AuthState.Unauthenticated, AuthState.Loading are nested types
        let authState = state.authState

        if let authenticatedState = authState as? AuthState.Authenticated {
            self.isAuthenticated = true
            self.currentUser = authenticatedState.user
        } else if authState is AuthState.Unauthenticated {
            self.isAuthenticated = false
            self.currentUser = nil
        } else if authState is AuthState.Loading {
            self.isLoading = true
        }
    }

    // MARK: - Authentication Actions (delegated to shared module)

    /// Sign up with email and password - delegates to shared ViewModel.
    func signUp(email: String, password: String) {
        sharedViewModel.signUp(email: email, password: password)
    }

    /// Login with email and password - delegates to shared ViewModel.
    func login(email: String, password: String) {
        sharedViewModel.login(email: email, password: password)
    }

    /// Sign in with Google credential - delegates to shared ViewModel.
    func signInWithGoogle(idToken: String, accessToken: String? = nil) {
        sharedViewModel.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }

    /// Logout the current user - delegates to shared ViewModel.
    func logout() {
        sharedViewModel.logout()
    }

    /// Clear error message - delegates to shared ViewModel.
    func clearError() {
        sharedViewModel.clearError()
    }
}


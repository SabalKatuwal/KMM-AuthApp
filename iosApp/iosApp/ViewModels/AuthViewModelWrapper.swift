import SwiftUI
import Combine
import FirebaseAuth

/// Native Swift AuthUser model (matching the KMM domain model).
struct AuthUserModel: Identifiable {
    let id: String
    let email: String?
    let displayName: String?
    let photoUrl: String?
    let isEmailVerified: Bool
    let isAnonymous: Bool

    init(uid: String, email: String?, displayName: String?, photoUrl: String?, isEmailVerified: Bool, isAnonymous: Bool) {
        self.id = uid
        self.email = email
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.isEmailVerified = isEmailVerified
        self.isAnonymous = isAnonymous
    }
}

/// Swift ViewModel that handles Firebase Authentication.
@MainActor
class AuthViewModelWrapper: ObservableObject {

    // Published properties that SwiftUI views can observe
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: AuthUserModel? = nil
    @Published var errorMessage: String? = nil

    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    /// Set up Firebase auth state listener.
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.isAuthenticated = true
                    self?.currentUser = user.toAuthUserModel()
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
                self?.isLoading = false
            }
        }
    }

    // MARK: - Authentication Actions

    /// Sign up with email and password.
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.mapFirebaseError(error)
                    return
                }

                if let user = authResult?.user {
                    self?.isAuthenticated = true
                    self?.currentUser = user.toAuthUserModel()
                }
            }
        }
    }

    /// Login with email and password.
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.mapFirebaseError(error)
                    return
                }

                if let user = authResult?.user {
                    self?.isAuthenticated = true
                    self?.currentUser = user.toAuthUserModel()
                }
            }
        }
    }

    /// Sign in with Google credential.
    func signInWithGoogle(idToken: String, accessToken: String? = nil) {
        isLoading = true
        errorMessage = nil

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken ?? "")

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.mapFirebaseError(error)
                    return
                }

                if let user = authResult?.user {
                    self?.isAuthenticated = true
                    self?.currentUser = user.toAuthUserModel()
                }
            }
        }
    }

    /// Logout the current user.
    func logout() {
        isLoading = true
        errorMessage = nil

        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    /// Clear error message.
    func clearError() {
        errorMessage = nil
    }

    /// Map Firebase errors to user-friendly messages
    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        let errorCode = AuthErrorCode(_bridgedNSError: nsError)

        switch errorCode?.code {
        case .wrongPassword, .invalidCredential:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyInUse:
            return "Email already in use"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network error occurred"
        case .invalidEmail:
            return "Invalid email address"
        default:
            return error.localizedDescription
        }
    }
}

// Extension to convert Firebase User to AuthUserModel
extension User {
    func toAuthUserModel() -> AuthUserModel {
        return AuthUserModel(
            uid: self.uid,
            email: self.email,
            displayName: self.displayName,
            photoUrl: self.photoURL?.absoluteString,
            isEmailVerified: self.isEmailVerified,
            isAnonymous: self.isAnonymous
        )
    }
}


import Foundation
import FirebaseAuth
import Shared

/**
 * Implementation of FirebaseAuthServiceDelegate from the shared KMM module.
 * This class bridges Swift Firebase SDK to the shared Kotlin module.
 *
 * ARCHITECTURE NOTE:
 * - This implements the `expect/actual` pattern's iOS side
 * - The shared module defines `FirebaseAuthServiceDelegate` interface
 * - This Swift class implements that interface using Firebase iOS SDK
 */
class FirebaseAuthDelegateImpl: NSObject, FirebaseAuthServiceDelegate {

    static let shared = FirebaseAuthDelegateImpl()

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var authStateCallback: ((AuthState) -> Void)?

    override init() {
        super.init()
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - FirebaseAuthServiceDelegate Implementation

    /// Get the current authenticated user, converting to shared module's AuthUser type.
    func getCurrentUser() -> AuthUser? {
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }
        return firebaseUser.toSharedAuthUser()
    }

    /// Setup Firebase auth state listener and notify the shared module via callback.
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let user = user {
                    // Convert Firebase User to shared AuthUser and create Authenticated state
                    let authUser = user.toSharedAuthUser()
                    let state = AuthState.Authenticated(user: authUser)
                    self.authStateCallback?(state)
                } else {
                    // User is not authenticated - use shared singleton
                    self.authStateCallback?(AuthState.Unauthenticated.shared)
                }
            }
        }
    }

    /// Observe auth state changes - called by the shared module.
    func observeAuthState(callback: @escaping (AuthState) -> Void) {
        self.authStateCallback = callback

        // Emit initial state
        if let user = Auth.auth().currentUser {
            callback(AuthState.Authenticated(user: user.toSharedAuthUser()))
        } else {
            callback(AuthState.Unauthenticated.shared)
        }
    }

    /// Sign up with email and password - returns result via callback to shared module.
    func signUpWithEmail(email: String, password: String, callback: @escaping (Any) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("signUpError: \(error)")
                    let authException = self.mapFirebaseErrorToAuthException(error)
                    callback(AuthResultError(exception: authException))
                    return
                }

                guard let user = authResult?.user else {
                    callback(AuthResultError(exception: AuthException.Unknown(message: "User creation failed")))
                    return
                }

                print("returned user from delegate: \(user)")
                callback(AuthResultSuccess(data: user.toSharedAuthUser()))
            }
        }
    }

    /// Login with email and password - returns result via callback to shared module.
    func loginWithEmail(email: String, password: String, callback: @escaping (Any) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    let authException = self.mapFirebaseErrorToAuthException(error)
                    callback(AuthResultError(exception: authException))
                    return
                }

                guard let user = authResult?.user else {
                    callback(AuthResultError(exception: AuthException.Unknown(message: "Login failed")))
                    return
                }

                callback(AuthResultSuccess(data: user.toSharedAuthUser()))
            }
        }
    }

    /// Sign in with Google credential - returns result via callback to shared module.
    func signInWithGoogle(idToken: String, accessToken: String?, callback: @escaping (Any) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken ?? "")

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    let authException = self.mapFirebaseErrorToAuthException(error)
                    callback(AuthResultError(exception: authException))
                    return
                }

                guard let user = authResult?.user else {
                    callback(AuthResultError(exception: AuthException.GoogleSignInFailed(message: "Google Sign-In failed")))
                    return
                }

                callback(AuthResultSuccess(data: user.toSharedAuthUser()))
            }
        }
    }

    /// Logout the current user - returns result via callback to shared module.
    func logout(callback: @escaping (Any) -> Void) {
        do {
            try Auth.auth().signOut()
            callback(AuthResultSuccess<KotlinUnit>(data: KotlinUnit()))
        } catch {
            callback(AuthResultError(exception: AuthException.Unknown(message: error.localizedDescription)))
        }
    }

    // MARK: - Error Mapping

    /// Map Firebase errors to shared module's AuthException types.
    private func mapFirebaseErrorToAuthException(_ error: Error) -> AuthException {
        let nsError = error as NSError

        // Check if it's a Firebase Auth error
        guard nsError.domain == AuthErrors.domain else {
            return AuthException.Unknown(message: error.localizedDescription)
        }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .wrongPassword, .invalidCredential:
            return AuthException.InvalidCredentials(message: "Invalid email or password")
        case .userNotFound:
            return AuthException.UserNotFound(message: "User not found")
        case .emailAlreadyInUse:
            return AuthException.EmailAlreadyInUse(message: "Email already in use")
        case .weakPassword:
            return AuthException.WeakPassword(message: "Password is too weak")
        case .networkError:
            return AuthException.NetworkError(message: "Network error occurred")
        case .invalidEmail:
            return AuthException.InvalidCredentials(message: "Invalid email address")
        default:
            return AuthException.Unknown(message: error.localizedDescription)
        }
    }
}

// MARK: - Firebase User Extension

/// Extension to convert Firebase User to the shared module's AuthUser type.
extension User {
    func toSharedAuthUser() -> AuthUser {
        return AuthUser(
            uid: self.uid,
            email: self.email,
            displayName: self.displayName,
            photoUrl: self.photoURL?.absoluteString,
            isEmailVerified: self.isEmailVerified,
            isAnonymous: self.isAnonymous
        )
    }
}


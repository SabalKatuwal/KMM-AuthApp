import Foundation
import FirebaseAuth

/// Native Swift AuthUser model
struct SwiftAuthUser {
    let uid: String
    let email: String?
    let displayName: String?
    let photoUrl: String?
    let isEmailVerified: Bool
    let isAnonymous: Bool
}

/// Native Swift AuthState enum
enum SwiftAuthState {
    case loading
    case authenticated(user: SwiftAuthUser)
    case unauthenticated
}

/// Native Swift AuthResult enum
enum SwiftAuthResult<T> {
    case success(T)
    case error(String)
    case loading
}

class FirebaseAuthManager: ObservableObject {

    static let shared = FirebaseAuthManager()

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var authStateCallback: ((SwiftAuthState) -> Void)?

    @Published var currentAuthState: SwiftAuthState = .loading

    private init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    func getCurrentUser() -> SwiftAuthUser? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return user.toSwiftAuthUser()
    }

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentAuthState = .authenticated(user: user.toSwiftAuthUser())
                } else {
                    self?.currentAuthState = .unauthenticated
                }
                self?.authStateCallback?(self?.currentAuthState ?? .unauthenticated)
            }
        }
    }

    func observeAuthState(callback: @escaping (SwiftAuthState) -> Void) {
        self.authStateCallback = callback
        // Immediately call with current state
        callback(currentAuthState)
    }

    func signUpWithEmail(email: String, password: String, completion: @escaping (SwiftAuthResult<SwiftAuthUser>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.error(self.mapFirebaseError(error)))
                    return
                }

                guard let user = authResult?.user else {
                    completion(.error("User creation failed"))
                    return
                }

                completion(.success(user.toSwiftAuthUser()))
            }
        }
    }

    func loginWithEmail(email: String, password: String, completion: @escaping (SwiftAuthResult<SwiftAuthUser>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.error(self.mapFirebaseError(error)))
                    return
                }

                guard let user = authResult?.user else {
                    completion(.error("Login failed"))
                    return
                }

                completion(.success(user.toSwiftAuthUser()))
            }
        }
    }

    func signInWithGoogle(idToken: String, accessToken: String?, completion: @escaping (SwiftAuthResult<SwiftAuthUser>) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken ?? "")

        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.error(self.mapFirebaseError(error)))
                    return
                }

                guard let user = authResult?.user else {
                    completion(.error("Google Sign-In failed"))
                    return
                }

                completion(.success(user.toSwiftAuthUser()))
            }
        }
    }

    func logout(completion: @escaping (SwiftAuthResult<Void>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.error(error.localizedDescription))
        }
    }

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

// Extension to convert Firebase User to SwiftAuthUser
extension User {
    func toSwiftAuthUser() -> SwiftAuthUser {
        return SwiftAuthUser(
            uid: self.uid,
            email: self.email,
            displayName: self.displayName,
            photoUrl: self.photoURL?.absoluteString,
            isEmailVerified: self.isEmailVerified,
            isAnonymous: self.isAnonymous
        )
    }
}


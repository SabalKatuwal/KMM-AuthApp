import Foundation
import GoogleSignIn

/// Helper class for Google Sign-In on iOS.
/// Handles the native Google Sign-In flow and returns credentials to the KMM layer.
class GoogleSignInHelper {

    static let shared = GoogleSignInHelper()

    private init() {}

    /// Performs Google Sign-In and returns the ID token and access token.
    /// - Parameter completion: Callback with result containing tokens or error.
    func signIn(presenting viewController: UIViewController, completion: @escaping (Result<(idToken: String, accessToken: String?), Error>) -> Void) {

        // Get the client ID from GoogleService-Info.plist
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            completion(.failure(GoogleSignInError.missingClientID))
            return
        }

        // Create Google Sign In configuration
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(GoogleSignInError.missingToken))
                return
            }

            let accessToken = user.accessToken.tokenString
            completion(.success((idToken: idToken, accessToken: accessToken)))
        }
    }

    /// Signs out from Google.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

/// Errors specific to Google Sign-In.
enum GoogleSignInError: LocalizedError {
    case missingClientID
    case missingToken
    case cancelled

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Firebase client ID not found. Make sure GoogleService-Info.plist is added to the project."
        case .missingToken:
            return "Failed to get ID token from Google"
        case .cancelled:
            return "Google Sign-In was cancelled"
        }
    }
}


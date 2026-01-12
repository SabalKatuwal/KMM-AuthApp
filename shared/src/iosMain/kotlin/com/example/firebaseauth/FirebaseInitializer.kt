package com.example.firebaseauth

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser

/**
 * iOS Firebase Auth Service delegate interface.
 * This will be implemented in Swift and set before using auth features.
 */
interface FirebaseAuthServiceDelegate {
    fun getCurrentUser(): AuthUser?
    fun observeAuthState(callback: (AuthState) -> Unit)
    fun signUpWithEmail(email: String, password: String, callback: (Any) -> Unit)
    fun loginWithEmail(email: String, password: String, callback: (Any) -> Unit)
    fun signInWithGoogle(idToken: String, accessToken: String?, callback: (Any) -> Unit)
    fun logout(callback: (Any) -> Unit)
}

/**
 * Holder for the iOS Firebase Auth delegate.
 * Must be set from Swift before using auth features.
 */
object IOSFirebaseAuth {
    var delegate: FirebaseAuthServiceDelegate? = null
}


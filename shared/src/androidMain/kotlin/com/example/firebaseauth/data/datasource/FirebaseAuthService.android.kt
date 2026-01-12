package com.example.firebaseauth.data.datasource

import com.example.firebaseauth.domain.model.AuthException
import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

/**
 * Android actual implementation of FirebaseAuthService.
 * TODO: Implement with Firebase Android SDK when needed.
 * For now, this is a stub implementation.
 */
actual class FirebaseAuthService actual constructor() {

    private val _authStateFlow = MutableStateFlow<AuthState>(AuthState.Unauthenticated)

    actual val authStateFlow: Flow<AuthState> = _authStateFlow

    actual fun getCurrentUser(): AuthUser? {
        // TODO: Implement with Firebase Android SDK
        return null
    }

    actual suspend fun signUpWithEmail(email: String, password: String): AuthResult<AuthUser> {
        // TODO: Implement with Firebase Android SDK
        return AuthResult.Error(AuthException.Unknown("Android implementation not yet available"))
    }

    actual suspend fun loginWithEmail(email: String, password: String): AuthResult<AuthUser> {
        // TODO: Implement with Firebase Android SDK
        return AuthResult.Error(AuthException.Unknown("Android implementation not yet available"))
    }

    actual suspend fun signInWithGoogle(idToken: String, accessToken: String?): AuthResult<AuthUser> {
        // TODO: Implement with Firebase Android SDK
        return AuthResult.Error(AuthException.Unknown("Android implementation not yet available"))
    }

    actual suspend fun logout(): AuthResult<Unit> {
        // TODO: Implement with Firebase Android SDK
        return AuthResult.Error(AuthException.Unknown("Android implementation not yet available"))
    }
}

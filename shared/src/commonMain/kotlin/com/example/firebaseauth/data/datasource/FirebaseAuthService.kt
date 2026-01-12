package com.example.firebaseauth.data.datasource

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import kotlinx.coroutines.flow.Flow

/**
 * Expected Firebase Auth service declaration.
 * Each platform provides its own implementation.
 */
expect class FirebaseAuthService() {
    /**
     * Observable flow of authentication state changes.
     */
    val authStateFlow: Flow<AuthState>

    /**
     * Get the currently authenticated user.
     */
    fun getCurrentUser(): AuthUser?

    /**
     * Sign up with email and password.
     */
    suspend fun signUpWithEmail(email: String, password: String): AuthResult<AuthUser>

    /**
     * Login with email and password.
     */
    suspend fun loginWithEmail(email: String, password: String): AuthResult<AuthUser>

    /**
     * Sign in with Google credential.
     */
    suspend fun signInWithGoogle(idToken: String, accessToken: String?): AuthResult<AuthUser>

    /**
     * Logout the current user.
     */
    suspend fun logout(): AuthResult<Unit>
}

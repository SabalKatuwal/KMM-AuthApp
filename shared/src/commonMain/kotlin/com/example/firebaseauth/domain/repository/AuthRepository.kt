package com.example.firebaseauth.domain.repository

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for authentication operations.
 * Defines the contract for auth operations - implementation is in data layer.
 */
interface AuthRepository {
    /**
     * Observable stream of authentication state changes.
     */
    val authStateFlow: Flow<AuthState>

    /**
     * Get the currently authenticated user, if any.
     */
    fun getCurrentUser(): AuthUser?

    /**
     * Sign up a new user with email and password.
     */
    suspend fun signUpWithEmail(email: String, password: String): AuthResult<AuthUser>

    /**
     * Log in an existing user with email and password.
     */
    suspend fun loginWithEmail(email: String, password: String): AuthResult<AuthUser>

    /**
     * Sign in with Google credential (ID token).
     */
    suspend fun signInWithGoogle(idToken: String, accessToken: String?): AuthResult<AuthUser>

    /**
     * Log out the current user.
     */
    suspend fun logout(): AuthResult<Unit>
}

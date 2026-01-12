package com.example.firebaseauth.domain.model

/**
 * Sealed class representing the authentication state.
 * Used for observing auth state changes reactively.
 */
sealed class AuthState {
    data object Loading : AuthState()
    data class Authenticated(val user: AuthUser) : AuthState()
    data object Unauthenticated : AuthState()
}

package com.example.firebaseauth.domain.model

/**
 * Sealed class representing the result of authentication operations.
 * Uses sealed class pattern for type-safe error handling.
 */
sealed class AuthResult<out T> {
    data class Success<T>(val data: T) : AuthResult<T>()
    data class Error(val exception: AuthException) : AuthResult<Nothing>()
    data object Loading : AuthResult<Nothing>()
}

/**
 * Domain-specific authentication exceptions.
 * Maps Firebase errors to domain-level errors.
 */
sealed class AuthException(override val message: String) : Exception(message) {
    data class InvalidCredentials(override val message: String = "Invalid email or password") : AuthException(message)
    data class UserNotFound(override val message: String = "User not found") : AuthException(message)
    data class EmailAlreadyInUse(override val message: String = "Email already in use") : AuthException(message)
    data class WeakPassword(override val message: String = "Password is too weak") : AuthException(message)
    data class NetworkError(override val message: String = "Network error occurred") : AuthException(message)
    data class GoogleSignInCancelled(override val message: String = "Google Sign-In was cancelled") : AuthException(message)
    data class GoogleSignInFailed(override val message: String = "Google Sign-In failed") : AuthException(message)
    data class Unknown(override val message: String = "An unknown error occurred") : AuthException(message)
}

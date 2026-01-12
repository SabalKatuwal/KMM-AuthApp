package com.example.firebaseauth.domain.model

/**
 * Domain model representing an authenticated user.
 * This is platform-agnostic and doesn't depend on Firebase SDK directly.
 */
data class AuthUser(
    val uid: String,
    val email: String?,
    val displayName: String?,
    val photoUrl: String?,
    val isEmailVerified: Boolean,
    val isAnonymous: Boolean
)

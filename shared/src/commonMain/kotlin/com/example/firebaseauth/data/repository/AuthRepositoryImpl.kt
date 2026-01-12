package com.example.firebaseauth.data.repository

import com.example.firebaseauth.data.datasource.FirebaseAuthService
import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow

/**
 * Implementation of AuthRepository using FirebaseAuthService.
 */
class AuthRepositoryImpl(
    private val firebaseAuthService: FirebaseAuthService
) : AuthRepository {

    override val authStateFlow: Flow<AuthState>
        get() = firebaseAuthService.authStateFlow

    override fun getCurrentUser(): AuthUser? {
        return firebaseAuthService.getCurrentUser()
    }

    override suspend fun signUpWithEmail(email: String, password: String): AuthResult<AuthUser> {
        return firebaseAuthService.signUpWithEmail(email, password)
    }

    override suspend fun loginWithEmail(email: String, password: String): AuthResult<AuthUser> {
        return firebaseAuthService.loginWithEmail(email, password)
    }

    override suspend fun signInWithGoogle(idToken: String, accessToken: String?): AuthResult<AuthUser> {
        return firebaseAuthService.signInWithGoogle(idToken, accessToken)
    }

    override suspend fun logout(): AuthResult<Unit> {
        return firebaseAuthService.logout()
    }
}

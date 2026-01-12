package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.domain.repository.AuthRepository

/**
 * Use case for signing in with Google.
 */
class GoogleSignInUseCase(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(idToken: String, accessToken: String? = null): AuthResult<AuthUser> {
        return authRepository.signInWithGoogle(idToken, accessToken)
    }
}

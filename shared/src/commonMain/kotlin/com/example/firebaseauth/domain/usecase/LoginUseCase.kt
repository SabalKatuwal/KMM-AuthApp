package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.domain.repository.AuthRepository

/**
 * Use case for logging in an existing user with email and password.
 */
class LoginUseCase(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): AuthResult<AuthUser> {
        return authRepository.loginWithEmail(email, password)
    }
}

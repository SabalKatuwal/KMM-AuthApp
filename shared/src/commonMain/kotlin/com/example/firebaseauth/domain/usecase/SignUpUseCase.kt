package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.domain.repository.AuthRepository

/**
 * Use case for signing up a new user with email and password.
 */
class SignUpUseCase(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): AuthResult<AuthUser> {
        return authRepository.signUpWithEmail(email, password)
    }
}

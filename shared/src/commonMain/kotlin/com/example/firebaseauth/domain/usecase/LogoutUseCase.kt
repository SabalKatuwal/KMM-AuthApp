package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.repository.AuthRepository

/**
 * Use case for logging out the current user.
 */
class LogoutUseCase(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(): AuthResult<Unit> {
        return authRepository.logout()
    }
}

package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.domain.repository.AuthRepository

/**
 * Use case for getting the currently authenticated user.
 */
class GetCurrentUserUseCase(
    private val authRepository: AuthRepository
) {
    operator fun invoke(): AuthUser? {
        return authRepository.getCurrentUser()
    }
}

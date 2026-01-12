package com.example.firebaseauth.domain.usecase

import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow

/**
 * Use case for observing authentication state changes.
 */
class ObserveAuthStateUseCase(
    private val authRepository: AuthRepository
) {
    operator fun invoke(): Flow<AuthState> {
        return authRepository.authStateFlow
    }
}

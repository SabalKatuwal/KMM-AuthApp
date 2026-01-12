package com.example.firebaseauth.di

import com.example.firebaseauth.data.datasource.FirebaseAuthService
import com.example.firebaseauth.data.repository.AuthRepositoryImpl
import com.example.firebaseauth.domain.repository.AuthRepository
import com.example.firebaseauth.domain.usecase.GetCurrentUserUseCase
import com.example.firebaseauth.domain.usecase.GoogleSignInUseCase
import com.example.firebaseauth.domain.usecase.LoginUseCase
import com.example.firebaseauth.domain.usecase.LogoutUseCase
import com.example.firebaseauth.domain.usecase.ObserveAuthStateUseCase
import com.example.firebaseauth.domain.usecase.SignUpUseCase

/**
 * Simple Service Locator for dependency injection.
 * In a production app, you might use Koin or similar DI framework.
 */
object ServiceLocator {

    // Data sources
    private val firebaseAuthService: FirebaseAuthService by lazy {
        FirebaseAuthService()
    }

    // Repositories
    val authRepository: AuthRepository by lazy {
        AuthRepositoryImpl(firebaseAuthService)
    }

    // Use cases
    val signUpUseCase: SignUpUseCase by lazy {
        SignUpUseCase(authRepository)
    }

    val loginUseCase: LoginUseCase by lazy {
        LoginUseCase(authRepository)
    }

    val logoutUseCase: LogoutUseCase by lazy {
        LogoutUseCase(authRepository)
    }

    val googleSignInUseCase: GoogleSignInUseCase by lazy {
        GoogleSignInUseCase(authRepository)
    }

    val getCurrentUserUseCase: GetCurrentUserUseCase by lazy {
        GetCurrentUserUseCase(authRepository)
    }

    val observeAuthStateUseCase: ObserveAuthStateUseCase by lazy {
        ObserveAuthStateUseCase(authRepository)
    }
}


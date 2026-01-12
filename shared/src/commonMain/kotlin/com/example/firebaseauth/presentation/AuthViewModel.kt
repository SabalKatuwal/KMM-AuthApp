package com.example.firebaseauth.presentation

import com.example.firebaseauth.di.ServiceLocator
import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * UI State for authentication screens.
 */
data class AuthUiState(
    val isLoading: Boolean = false,
    val authState: AuthState = AuthState.Loading,
    val errorMessage: String? = null
)

/**
 * Shared ViewModel for authentication.
 * This class contains the presentation logic and can be consumed by iOS through a wrapper.
 */
class AuthViewModel {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private val signUpUseCase = ServiceLocator.signUpUseCase
    private val loginUseCase = ServiceLocator.loginUseCase
    private val logoutUseCase = ServiceLocator.logoutUseCase
    private val googleSignInUseCase = ServiceLocator.googleSignInUseCase
    private val getCurrentUserUseCase = ServiceLocator.getCurrentUserUseCase
    private val observeAuthStateUseCase = ServiceLocator.observeAuthStateUseCase

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        observeAuthState()
    }

    /**
     * Start observing authentication state changes.
     */
    private fun observeAuthState() {
        scope.launch {
            observeAuthStateUseCase().collect { authState ->
                _uiState.value = _uiState.value.copy(
                    authState = authState,
                    isLoading = false
                )
            }
        }
    }

    /**
     * Sign up with email and password.
     */
    fun signUp(email: String, password: String) {
        scope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)

            val result = signUpUseCase(email, password)
            handleAuthResult(result)
        }
    }

    /**
     * Login with email and password.
     */
    fun login(email: String, password: String) {
        scope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)

            val result = loginUseCase(email, password)
            handleAuthResult(result)
        }
    }

    /**
     * Sign in with Google.
     */
    fun signInWithGoogle(idToken: String, accessToken: String? = null) {
        scope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)

            val result = googleSignInUseCase(idToken, accessToken)
            handleAuthResult(result)
        }
    }

    /**
     * Logout the current user.
     */
    fun logout() {
        scope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)

            val result = logoutUseCase()
            when (result) {
                is AuthResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        authState = AuthState.Unauthenticated
                    )
                }
                is AuthResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.exception.message
                    )
                }
                is AuthResult.Loading -> { /* Already handled */ }
            }
        }
    }

    private fun handleAuthResult(result: AuthResult<AuthUser>) {
        when (result) {
            is AuthResult.Success -> {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    authState = AuthState.Authenticated(result.data)
                )
            }
            is AuthResult.Error -> {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = result.exception.message
                )
            }
            is AuthResult.Loading -> { /* Already handled */ }
        }
    }

    /**
     * Get the currently authenticated user.
     */
    fun getCurrentUser(): AuthUser? {
        return getCurrentUserUseCase()
    }

    /**
     * Clear any error messages.
     */
    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    /**
     * Clean up resources when ViewModel is no longer needed.
     */
    fun onCleared() {
        scope.cancel()
    }
}


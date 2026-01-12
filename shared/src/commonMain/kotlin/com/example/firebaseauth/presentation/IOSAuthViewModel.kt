package com.example.firebaseauth.presentation

import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import com.example.firebaseauth.util.Closeable
import com.example.firebaseauth.util.FlowWrapper

/**
 * iOS-friendly wrapper for AuthViewModel.
 * This class provides a bridge between Kotlin Coroutines/Flows and Swift callbacks.
 */
class IOSAuthViewModel {

    private val viewModel = AuthViewModel()

    /**
     * Wrapper for the UI state flow that can be observed from iOS.
     */
    val uiState: FlowWrapper<AuthUiState> = FlowWrapper(viewModel.uiState)

    /**
     * Subscribe to UI state changes.
     */
    fun observeUiState(onStateChange: (AuthUiState) -> Unit): Closeable {
        return uiState.subscribe(onEach = onStateChange)
    }

    /**
     * Get the current auth state.
     */
    fun getCurrentAuthState(): AuthState {
        return uiState.value.authState
    }

    /**
     * Check if user is authenticated.
     */
    fun isAuthenticated(): Boolean {
        return uiState.value.authState is AuthState.Authenticated
    }

    /**
     * Get the current user if authenticated.
     */
    fun getCurrentUser(): AuthUser? {
        val state = uiState.value.authState
        return if (state is AuthState.Authenticated) {
            state.user
        } else {
            null
        }
    }

    /**
     * Sign up with email and password.
     */
    fun signUp(email: String, password: String) {
        viewModel.signUp(email, password)
    }

    /**
     * Login with email and password.
     */
    fun login(email: String, password: String) {
        viewModel.login(email, password)
    }

    /**
     * Sign in with Google credential.
     */
    fun signInWithGoogle(idToken: String, accessToken: String?) {
        viewModel.signInWithGoogle(idToken, accessToken)
    }

    /**
     * Logout the current user.
     */
    fun logout() {
        viewModel.logout()
    }

    /**
     * Clear error message.
     */
    fun clearError() {
        viewModel.clearError()
    }

    /**
     * Clean up resources.
     */
    fun onCleared() {
        viewModel.onCleared()
    }
}

/**
 * Factory function to create IOSAuthViewModel from Swift.
 */
fun createAuthViewModel(): IOSAuthViewModel {
    return IOSAuthViewModel()
}


package com.example.firebaseauth.data.datasource

import com.example.firebaseauth.FirebaseAuthServiceDelegate
import com.example.firebaseauth.IOSFirebaseAuth
import com.example.firebaseauth.domain.model.AuthResult
import com.example.firebaseauth.domain.model.AuthState
import com.example.firebaseauth.domain.model.AuthUser
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

/**
 * iOS actual implementation of FirebaseAuthService.
 * Delegates to the Swift implementation via IOSFirebaseAuth.delegate.
 */
actual class FirebaseAuthService actual constructor() {

    private val delegate: FirebaseAuthServiceDelegate
        get() = IOSFirebaseAuth.delegate
            ?: throw IllegalStateException("IOSFirebaseAuth.delegate must be set before using FirebaseAuthService")

    actual val authStateFlow: Flow<AuthState> = callbackFlow {
        delegate.observeAuthState { state ->
            trySend(state)
        }
        awaitClose { }
    }

    actual fun getCurrentUser(): AuthUser? {
        return delegate.getCurrentUser()
    }

    @Suppress("UNCHECKED_CAST")
    actual suspend fun signUpWithEmail(email: String, password: String): AuthResult<AuthUser> {
        return suspendCancellableCoroutine { continuation ->
            delegate.signUpWithEmail(email, password) { result ->
                continuation.resume(result as AuthResult<AuthUser>)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    actual suspend fun loginWithEmail(email: String, password: String): AuthResult<AuthUser> {
        return suspendCancellableCoroutine { continuation ->
            delegate.loginWithEmail(email, password) { result ->
                continuation.resume(result as AuthResult<AuthUser>)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    actual suspend fun signInWithGoogle(idToken: String, accessToken: String?): AuthResult<AuthUser> {
        return suspendCancellableCoroutine { continuation ->
            delegate.signInWithGoogle(idToken, accessToken) { result ->
                continuation.resume(result as AuthResult<AuthUser>)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    actual suspend fun logout(): AuthResult<Unit> {
        return suspendCancellableCoroutine { continuation ->
            delegate.logout { result ->
                // Convert AuthResult<KotlinUnit> to AuthResult<Unit>
                val convertedResult = when (result) {
                    is AuthResult.Success<*> -> AuthResult.Success(Unit)
                    is AuthResult.Error -> result
                    else -> result as AuthResult<Unit>
                }
                continuation.resume(convertedResult)
            }
        }
    }
}


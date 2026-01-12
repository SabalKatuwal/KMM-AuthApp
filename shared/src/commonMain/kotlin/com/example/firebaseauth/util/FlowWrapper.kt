package com.example.firebaseauth.util

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/**
 * A wrapper class that makes Kotlin StateFlow observable from Swift/iOS.
 * This allows iOS to observe state changes using callbacks.
 */
class FlowWrapper<T>(
    private val stateFlow: StateFlow<T>
) {
    /**
     * Get the current value.
     */
    val value: T
        get() = stateFlow.value

    private var job: Job? = null

    /**
     * Subscribe to state changes with a callback.
     * Returns a Closeable that can be used to cancel the subscription.
     */
    fun subscribe(
        scope: CoroutineScope = CoroutineScope(Dispatchers.Main),
        onEach: (T) -> Unit
    ): Closeable {
        job = scope.launch {
            stateFlow.collect { value ->
                onEach(value)
            }
        }
        return object : Closeable {
            override fun close() {
                job?.cancel()
                job = null
            }
        }
    }
}

/**
 * Interface for closing/cancelling subscriptions.
 */
interface Closeable {
    fun close()
}


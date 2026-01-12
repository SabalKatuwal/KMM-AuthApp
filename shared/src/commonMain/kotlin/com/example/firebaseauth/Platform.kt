package com.example.firebaseauth

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
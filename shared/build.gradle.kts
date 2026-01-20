import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
    
    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "Shared"
            isStatic = true
            // Export all types with proper names
            binaryOption("bundleId", "com.example.firebaseauth.Shared")
        }
    }
    
    sourceSets {
        commonMain.dependencies {
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

// Task to create symlinks for xcode-frameworks (used by Xcode build phase)
tasks.register("createXcodeFrameworksSymlink") {
    doLast {
        val buildDir = layout.buildDirectory.get().asFile
        val xcodeFrameworksDir = File(buildDir, "xcode-frameworks")

        // Create Debug and Release directories
        listOf("Debug", "Release").forEach { config ->
            listOf("iphoneos", "iphonesimulator").forEach { sdk ->
                val targetDir = File(xcodeFrameworksDir, "$config/$sdk")
                targetDir.mkdirs()

                // Determine source framework
                val sourceFrameworkDir = when {
                    sdk == "iphonesimulator" && config == "Debug" ->
                        File(buildDir, "bin/iosSimulatorArm64/debugFramework/Shared.framework")
                    sdk == "iphonesimulator" && config == "Release" ->
                        File(buildDir, "bin/iosSimulatorArm64/releaseFramework/Shared.framework")
                    sdk == "iphoneos" && config == "Debug" ->
                        File(buildDir, "bin/iosArm64/debugFramework/Shared.framework")
                    else ->
                        File(buildDir, "bin/iosArm64/releaseFramework/Shared.framework")
                }

                val targetFramework = File(targetDir, "Shared.framework")
                if (!targetFramework.exists() && sourceFrameworkDir.exists()) {
                    // Create symlink
                    Runtime.getRuntime().exec(arrayOf("ln", "-sf", sourceFrameworkDir.absolutePath, targetFramework.absolutePath))
                }
            }
        }
    }
}

android {
    namespace = "com.example.firebaseauth.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
}

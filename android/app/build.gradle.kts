plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myusic"
    compileSdk = 36   // 🔥 updated to highest required by plugins
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.myusic"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ✅ Java compiler settings
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ✅ Kotlin compiler settings
    kotlinOptions {
        jvmTarget = "17"
    }
}

// ✅ Force Kotlin JVM toolchain
kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

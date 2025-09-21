plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.example.tionova"
    compileSdk = 36
    ndkVersion = "28.0.13004108"
    
    // Add SHA-1 for Google Sign-In
   
 compileOptions {
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.tionova"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Ensure R8/ProGuard keeps required classes (e.g., TensorFlow Lite GPU)
            isMinifyEnabled = true
            // Remove unused resources alongside code shrinking to reduce APK size
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )
        }
    }

    // Generate smaller, per-ABI APKs instead of a single fat APK
    splits {
        abi {
            isEnable = true
            reset()
            // Include common ABIs for both device (ARM) and emulator (x86_64)
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            // Keep a universal APK in debug runs to avoid missing libflutter.so
            isUniversalApk = true
        }
    }

    // Exclude unnecessary META-INF artifacts to slightly reduce size
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1,LICENSE*,NOTICE*,*.kotlin_module}"
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
}

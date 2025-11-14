# URGENT FIX: App Stuck on Splash Screen (Android)

## Problem
App is stuck on a black or white screen and never shows the Flutter UI.

## Root Cause
The `setKeepOnScreenCondition { true }` in MainActivity.kt was keeping the splash screen visible forever because the condition always returns `true`.

## Solution ✅

### Fixed Code (MainActivity.kt)

**WRONG ❌ - This will freeze the app:**
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    val splashScreen = installSplashScreen()
    splashScreen.setKeepOnScreenCondition { true }  // ❌ NEVER DO THIS!
}
```

**CORRECT ✅ - This works properly:**
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    installSplashScreen()  // ✅ Automatically dismisses when Flutter is ready
}
```

## How It Works

### The Android 12+ SplashScreen API Behavior:

1. **`installSplashScreen()`** - Installs the splash screen handler
2. **Automatic Dismissal** - By default, it automatically dismisses when:
   - Flutter draws its first frame
   - The activity's `onResume()` is called
   - The window's first frame is drawn

3. **`setKeepOnScreenCondition { condition }`** - Optional method to delay dismissal
   - Should return `false` when ready to dismiss
   - Should return `true` only temporarily while loading
   - **Never use `{ true }` as it will never dismiss!**

## Quick Fix Steps

1. **Edit MainActivity.kt:**
   ```bash
   # Location: android/app/src/main/kotlin/com/example/tionova/MainActivity.kt
   ```

2. **Remove the problematic line:**
   ```kotlin
   // Remove this entire line:
   splashScreen.setKeepOnScreenCondition { true }
   ```

3. **Simplify to just:**
   ```kotlin
   installSplashScreen()
   ```

4. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Complete MainActivity.kt (Correct Version)

```kotlin
package com.example.tionova

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Install splash screen handler for Android 12+
        // Splash will automatically dismiss when Flutter draws first frame
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            installSplashScreen()
        }
        
        // Set transparent status bar for seamless transition
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BOUNDARIES)
            window.statusBarColor = 0x00000000 // Transparent
        }
        
        super.onCreate(savedInstanceState)
    }
}
```

## Why This Happens

### Understanding `setKeepOnScreenCondition`

This method accepts a lambda that's evaluated repeatedly:
```kotlin
splashScreen.setKeepOnScreenCondition { 
    // This lambda is called many times
    // Return true = keep splash visible
    // Return false = dismiss splash
}
```

**Examples:**

**Wrong ❌:**
```kotlin
setKeepOnScreenCondition { true }  // Always true = never dismisses
```

**Correct for custom logic ✅:**
```kotlin
var isLoading = true

setKeepOnScreenCondition { isLoading }  // Will dismiss when isLoading becomes false

// Later in your code:
loadDataAsync {
    isLoading = false  // Now splash will dismiss
}
```

**Best for our case ✅:**
```kotlin
// Just don't use it at all!
installSplashScreen()  // Auto-dismisses when Flutter is ready
```

## Testing the Fix

1. **Uninstall old app:**
   ```bash
   # Remove the app completely from device/emulator
   adb uninstall com.example.tionova
   ```

2. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Install fresh:**
   ```bash
   flutter run --release
   # or
   flutter build apk --release
   ```

4. **Verify:**
   - App should show transparent/system splash briefly
   - Then Flutter splash (TioNovaspalsh.dart) appears
   - Then navigates to theme-selection or auth
   - **No stuck screen!**

## Expected Behavior After Fix

```
User taps app icon
       ↓
Brief transparent splash (Android 12+ system) - 50-200ms
       ↓
Flutter initializes
       ↓
TioNovaspalsh.dart renders (animated TIONOVA text) - 3 seconds
       ↓
Navigate to /theme-selection or /auth
       ↓
App content shows
```

**Total time:** ~3-4 seconds (normal)

## If Still Stuck

### Check These:

1. **Is Flutter initializing?**
   ```bash
   # Check logcat for Flutter messages
   adb logcat | grep Flutter
   ```

2. **Any errors in main.dart?**
   - Check if Firebase initialization fails
   - Check if Hive initialization fails
   - Check if any services are blocking

3. **Is splash screen visible?**
   ```bash
   # Check logcat for SplashScreen messages
   adb logcat | grep SplashScreen
   ```

4. **Try without splash screen API:**
   ```kotlin
   // Temporarily comment out to test
   // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
   //     installSplashScreen()
   // }
   ```

## Summary

✅ **Fixed:** Removed `setKeepOnScreenCondition { true }`  
✅ **Changed to:** Just `installSplashScreen()`  
✅ **Result:** Splash automatically dismisses when Flutter is ready  
✅ **Status:** Ready to test  

---

**Fixed:** November 13, 2025  
**Issue:** App stuck on splash screen  
**Solution:** Remove infinite splash condition  
**Status:** ✅ RESOLVED

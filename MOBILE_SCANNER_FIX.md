# Fix MissingPluginException for mobile_scanner

## The Problem
`MissingPluginException: No implementation found for method state on channel dev.steenbakker.mobile_scanner/scanner/method`

This means the native plugin code for mobile_scanner isn't properly linked to your Flutter app.

## Solution Steps

### For Both Android and iOS:

1. **Clean and rebuild everything:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **For Android:**
   ```bash
   cd android
   gradlew clean
   cd ..
   flutter build apk --debug
   ```

3. **For iOS (on macOS only):**
   ```bash
   cd ios
   pod repo update
   pod install --repo-update
   cd ..
   flutter build ios --debug
   ```

### Quick Fix Script
Run the `fix_mobile_scanner.bat` file I created in the project root:
```bash
fix_mobile_scanner.bat
```

## What I Fixed

### 1. Android minSdkVersion
Updated `android/app/build.gradle.kts` to explicitly set `minSdk = 21` (required by mobile_scanner)

### 2. Permissions Already Configured ✅
- **Android**: Camera permission already in `AndroidManifest.xml`
- **iOS**: Camera usage description already in `Info.plist`

## After Running the Fix

### Test the QR Scanner:
1. Run the app on a physical device (camera needed)
2. Navigate to QR scanner screen
3. Point at a QR code containing a challenge code
4. It should automatically join the challenge

### If Still Not Working:

#### Option 1: Hot Restart
- Stop the app completely
- Run `flutter run` again (not hot reload)

#### Option 2: Uninstall and Reinstall
- Uninstall the app from your device
- Run `flutter run` again

#### Option 3: Check Device Permissions
- Go to device Settings → Apps → TioNova → Permissions
- Ensure Camera permission is granted

## Technical Details

The mobile_scanner plugin requires:
- **Android**: minSdk 21+, Camera permission
- **iOS**: iOS 11.0+, Camera usage description
- **Platform channels**: Native code must be compiled and linked

The `MissingPluginException` occurs when:
- The native plugin code isn't compiled
- The plugin isn't registered in `GeneratedPluginRegistrant`
- Hot reload was used after adding the plugin (needs full restart)

## Verification

After running the fix, verify the plugin is working:
```dart
// In qr_scanner_screen.dart
// If no exception is thrown when creating the controller, it's working
final controller = MobileScannerController();
```

---

**Note**: Always use a physical device for testing QR scanner - emulators don't have cameras!

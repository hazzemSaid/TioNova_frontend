@echo off
echo ============================================================
echo Fixing mobile_scanner MissingPluginException
echo ============================================================
echo.
echo This will:
echo  1. Clean Flutter build cache
echo  2. Re-fetch all dependencies
echo  3. Clean Android Gradle build
echo  4. Rebuild the app
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo [1/5] Cleaning Flutter build cache...
flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo.
echo [2/5] Getting Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo [3/5] Cleaning Android Gradle build...
cd android
call gradlew.bat clean
if errorlevel 1 (
    echo WARNING: Gradle clean failed, continuing anyway...
)
cd ..

echo.
echo [4/5] Building Android APK...
echo This will take a few minutes...
flutter build apk --debug
if errorlevel 1 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo.
echo [5/5] Installing to connected device...
flutter install
if errorlevel 1 (
    echo WARNING: Install failed. Make sure a device is connected.
    echo You can manually install the APK from: build\app\outputs\flutter-apk\app-debug.apk
)

echo.
echo ============================================================
echo SUCCESS! The mobile_scanner plugin should now work.
echo ============================================================
echo.
echo Next steps:
echo  1. Open the app on your physical device
echo  2. Go to the QR scanner screen
echo  3. Point at a QR code with a challenge code
echo  4. The app should automatically join the challenge
echo.
echo If it still doesn't work:
echo  - Uninstall the app completely from your device
echo  - Run: flutter run
echo  - Grant camera permissions when prompted
echo.
pause


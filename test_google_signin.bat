@echo off
echo ========================================
echo   Google Sign-In Web Testing Script
echo ========================================
echo.

echo [1/5] Cleaning Flutter project...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo ✓ Clean completed
echo.

echo [2/5] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo [3/5] Checking index.html configuration...
findstr /C:"accounts.google.com/gsi/client" web\index.html >nul
if %errorlevel% equ 0 (
    echo ✓ Google Sign-In script found in index.html
) else (
    echo ✗ WARNING: Google Sign-In script NOT found in index.html
    echo   Please check web\index.html
)
echo.

echo [4/5] Checking auth_service.dart configuration...
findstr /C:"GoogleSignIn" lib\features\auth\data\services\auth_service.dart >nul
if %errorlevel% equ 0 (
    echo ✓ GoogleSignIn found in auth_service.dart
) else (
    echo ✗ WARNING: GoogleSignIn NOT found in auth_service.dart
)
echo.

echo [5/5] Starting Flutter web app in Chrome...
echo.
echo ========================================
echo   TESTING INSTRUCTIONS:
echo ========================================
echo 1. Wait for Chrome to open
echo 2. Press F12 to open DevTools
echo 3. Go to Console tab
echo 4. Click "Continue with Google" button
echo 5. Check the console for debug messages:
echo    - Look for 🔵 [Google Sign-In] messages
echo    - Look for ✅ success messages
echo    - Look for ❌ error messages
echo.
echo 6. Common issues:
echo    - "idpiframe_initialization_failed" = Script not loaded
echo    - "redirect_uri_mismatch" = Check Google Console
echo    - "origin_mismatch" = Wrong client ID
echo.
echo Press Ctrl+C to stop the server when done testing
echo ========================================
echo.

call flutter run -d chrome --web-port=5000
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to run Flutter app!
    echo.
    echo Troubleshooting:
    echo - Make sure Chrome is installed
    echo - Check if port 5000 is available
    echo - Try running: flutter devices
    pause
    exit /b 1
)

pause

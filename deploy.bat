@echo off
echo ========================================
echo   TioNova - Vercel Deployment Script
echo ========================================
echo.

echo [Step 1/4] Cleaning previous build...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b %errorlevel%
)
echo ✓ Clean completed
echo.

echo [Step 2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b %errorlevel%
)
echo ✓ Dependencies installed
echo.

echo [Step 3/4] Building Flutter Web App for production...
call flutter build web --release --web-renderer auto
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter build failed!
    echo Please fix the build errors and try again.
    pause
    exit /b %errorlevel%
)
echo.
echo ✓ Build completed successfully!
echo.

echo [Step 4/4] Deploying to Vercel...
echo.
set /p deploy_type="Deploy to (1) Preview or (2) Production? [1/2]: "

if "%deploy_type%"=="2" (
    echo.
    echo 🚀 Deploying to PRODUCTION...
    echo URL: https://tio-nova-frontend.vercel.app
    echo.
    vercel --prod --yes
) else (
    echo.
    echo 🔍 Deploying to PREVIEW...
    echo.
    vercel --yes
)

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Vercel deployment failed!
    echo.
    echo Possible fixes:
    echo 1. Install Vercel CLI: npm install -g vercel
    echo 2. Login to Vercel: vercel login
    echo 3. Link project: vercel link
    pause
    exit /b %errorlevel%
)

echo.
echo ========================================
echo   ✅ Deployment Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Test the deployment URL
echo 2. Try Google Sign-In
echo 3. Check browser console for errors
echo.
pause

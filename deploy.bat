@echo off
echo ========================================
echo TioNova - Vercel Deployment Script
echo ========================================
echo.

echo Step 1: Building Flutter Web App...
flutter build web --release

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
echo Step 2: Deploying to Vercel...
echo.

set /p deploy_type="Deploy to (1) Preview or (2) Production? [1/2]: "

if "%deploy_type%"=="2" (
    echo.
    echo Deploying to PRODUCTION...
    vercel --prod --yes --build-env OUTPUT_DIRECTORY=build/web
) else (
    echo.
    echo Deploying to PREVIEW...
    vercel --yes --build-env OUTPUT_DIRECTORY=build/web
)

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
pause

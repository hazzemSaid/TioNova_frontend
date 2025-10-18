# Vercel CLI Deployment Guide for TioNova

## Prerequisites
✅ Vercel CLI is already installed (v48.0.2)

## Quick Deployment Steps

### 1. Login to Vercel (if not already logged in)
```bash
vercel login
```
This will open your browser to authenticate.

### 2. Build Flutter Web App Locally
```bash
flutter build web --release --no-wasm-dry-run
```
This builds your app to the `build/web` directory.

### 3. Deploy to Preview (Development)
```bash
vercel --yes --build-env OUTPUT_DIRECTORY=build/web
```
This command will deploy your pre-built app to a preview URL.

### 4. Deploy to Production
```bash
vercel --prod --yes --build-env OUTPUT_DIRECTORY=build/web
```
This deploys to your production domain.

### 5. Use the Deployment Script (Easiest)
```bash
deploy.bat
```
This automates the entire build and deployment process.

## Detailed Deployment Process

### First Time Setup
When you run `vercel` for the first time, you'll be asked:

1. **Set up and deploy?** → Yes
2. **Which scope?** → Select your account/team
3. **Link to existing project?** → No (or Yes if you already created one)
4. **Project name?** → tionova (or press Enter to use default)
5. **Directory?** → ./ (press Enter)
6. **Override settings?** → No (our vercel.json handles this)

### Environment Variables (if needed)

If your app needs environment variables (API keys, Firebase config, etc.):

#### Add via CLI:
```bash
vercel env add VARIABLE_NAME
```
Then select the environment (production/preview/development) and enter the value.

#### Add via Dashboard:
1. Go to https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Environment Variables
4. Add your variables

### Common Commands

```bash
# Preview deployment (with build logs)
vercel --debug

# Production deployment
vercel --prod

# View deployment logs
vercel logs

# List all deployments
vercel ls

# View project info
vercel inspect

# Remove a deployment
vercel remove [deployment-url]

# Pull environment variables to local
vercel env pull

# Link local project to Vercel project
vercel link
```

## Project Configuration

Your project is configured with:

### vercel.json
- Build Command: `flutter build web --release`
- Output Directory: `build/web`
- Install Command: `flutter pub get`
- Routes configured for SPA (Single Page Application)

### package.json
- Contains the build script for Vercel to execute
- Specifies project metadata

## Troubleshooting

### Build Fails
1. Ensure Flutter is available in Vercel's build environment
2. Check the build logs: `vercel logs`
3. Test local build: `flutter build web --release`

### Environment Issues
If Vercel doesn't have Flutter installed by default, you may need to:
1. Use Vercel's custom build image
2. Or deploy the pre-built `build/web` folder directly:
   ```bash
   # Build locally first
   flutter build web --release
   
   # Deploy the build folder
   vercel --prod
   ```

### Routes Not Working
- Ensure `vercel.json` has the catch-all route: `"src": "/(.*)", "dest": "/index.html"`
- This enables Flutter's client-side routing

## Production Checklist

Before deploying to production:

- [ ] Test the build locally: `flutter build web --release`
- [ ] Check `build/web` folder is created
- [ ] Add all necessary environment variables
- [ ] Update any API endpoints to production URLs
- [ ] Test preview deployment first: `vercel`
- [ ] Then deploy to production: `vercel --prod`

## Useful Links

- Vercel Dashboard: https://vercel.com/dashboard
- Vercel Docs: https://vercel.com/docs
- Flutter Web Docs: https://docs.flutter.dev/platform-integration/web

## Quick Reference

```bash
# Full deployment workflow
flutter build web --release    # Build locally (optional but recommended)
vercel login                   # Login (first time)
vercel                         # Preview deployment
vercel --prod                  # Production deployment
```

## Notes

- Preview deployments get a unique URL for testing
- Production deployments go to your main domain
- Each deployment is immutable and can be rolled back
- Build time: ~2-5 minutes depending on project size

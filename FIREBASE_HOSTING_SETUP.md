# Firebase Hosting Deployment Guide for TioNova

## Prerequisites

1. **Firebase CLI installed** - Required to deploy
   ```bash
   npm install -g firebase-tools
   ```

2. **Node.js and npm installed** - For Firebase CLI
   - Download from https://nodejs.org

3. **Flutter SDK** - Already configured in your project

## Setup Steps

### Step 1: Login to Firebase
```bash
firebase login
```
This will open your browser to authenticate with your Google account.

### Step 2: Verify Firebase Project
```bash
firebase projects:list
```
You should see `tionova-c566b` in the list.

### Step 3: Build Flutter Web
```bash
flutter clean
flutter pub get
flutter build web --release
```
This creates the optimized build in `build/web/`.

### Step 4: Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

## Complete Deployment Script

Run this from your project root:

```bash
# Login (if not already logged in)
firebase login

# Clean and build
flutter clean
flutter pub get
flutter build web --release

# Deploy
firebase deploy --only hosting
```

## Deployment Output

After successful deployment, you'll see:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/tionova-c566b
Hosting URL: https://tionova-c566b.web.app
```

Your app will be live at `https://tionova-c566b.web.app`

## Important Configuration Details

### firebase.json Configuration
```json
{
  "hosting": {
    "public": "build/web",           // Flutter web output directory
    "ignore": [                       // Files to ignore during deployment
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [                     // Rewrite for SPA routing
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

The `rewrites` rule is crucial for Flutter web apps - it ensures all routes are handled by your Flutter app.

## Environment-Specific Deployment

### Deploy to staging (if configured)
```bash
firebase deploy --only hosting --project tionova-c566b
```

### Monitor Deployment Status
```bash
firebase hosting:sites:list
```

## Troubleshooting

### Issue: "Missing 'public' directory"
**Solution**: Build Flutter web first
```bash
flutter build web --release
```

### Issue: "You do not have permission to access this project"
**Solution**: 
1. Run `firebase logout`
2. Run `firebase login` and select the correct Google account
3. Verify with `firebase projects:list`

### Issue: "Routes not working (404 errors)"
**Solution**: The rewrites rule in `firebase.json` handles this. It's already configured.

### Issue: "Assets not loading (blank page)"
**Solution**: 
1. Clear browser cache
2. Do a hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. Verify build completed successfully with no errors

## Performance Optimization

### Enable Gzip Compression
Already handled by Firebase Hosting by default.

### Set Cache Headers
Firebase Hosting automatically sets appropriate cache headers for:
- HTML files: No cache
- JS/CSS/Images: 1 year cache (with hash-based versioning)

### Reduce Build Size

Add to `pubspec.yaml`:
```yaml
flutter:
  enable-web-build-optimizations: true
```

Build with:
```bash
flutter build web --release --web-renderer html
```

## Post-Deployment

### Monitor Your Hosted App
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select `tionova-c566b` project
3. Go to Hosting → Dashboard
4. View analytics and traffic

### View Logs
```bash
firebase hosting:log
```

### Rollback to Previous Version
```bash
firebase hosting:channel:list
firebase hosting:clone
```

## Continuous Deployment

### GitHub Actions Integration (Optional)

Create `.github/workflows/firebase-deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.0'
      
      - name: Build Flutter Web
        run: |
          flutter clean
          flutter pub get
          flutter build web --release
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: tionova-c566b
          channelId: live
```

## Useful Commands

```bash
# List all hosting sites
firebase hosting:sites:list

# View current deployment
firebase hosting:channels:list

# Create staging channel
firebase hosting:channel:create staging

# Deploy to staging
firebase deploy --only hosting --channel=staging

# Promote staging to live
firebase hosting:channels:promote staging

# Delete old deployments
firebase hosting:delete
```

## Security Considerations

1. **HTTPS**: Firebase Hosting automatically provides HTTPS
2. **Security Headers**: Already configured by Firebase
3. **CORS**: Configure in Firebase Console if needed for API calls
4. **API Keys**: Use environment-specific configuration
   - Web API key is safe to expose (it's restricted by domain)
   - Keep backend API keys secure

## Next Steps

1. Ensure your Firebase Realtime Database rules are properly configured
2. Set up Firebase Security Rules for all collections
3. Configure Firestore/Realtime Database access rules
4. Test all authentication flows on the hosted app
5. Set up monitoring and error tracking

## Support Resources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
- [Firebase Console](https://console.firebase.google.com)

---

**Your Firebase Hosting URL**: `https://tionova-c566b.web.app`
**Project ID**: `tionova-c566b`

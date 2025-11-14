# Shorebird Code Push Setup Guide

## 📋 Overview

TioNova is configured with **Shorebird Code Push** for over-the-air (OTA) updates. This allows you to push bug fixes and feature updates to users without waiting for App Store/Play Store review.

## ✅ Current Status

- ✅ Shorebird initialized with App ID: `0313e70d-2162-4191-bcc5-75abb03f3cdc`
- ✅ First release (v1.0.0+1) published
- ✅ First patch published successfully
- ✅ Update checker service integrated in app
- ✅ Auto-update UI implemented

## 🎯 How It Works

### In Development (Debug Mode)
- Shorebird features are **disabled** in debug mode
- The app will show logs indicating Shorebird is not active
- This is **expected behavior** - no errors!

### In Production (Release Mode)
- Shorebird automatically checks for updates on app start
- Checks periodically every 30 minutes
- Shows user-friendly dialog when updates are available
- Downloads and applies patches seamlessly

## 📦 Important: Package Management

**DO NOT** add `shorebird_code_push` to `pubspec.yaml` manually!

❌ **WRONG:**
```yaml
dependencies:
  shorebird_code_push: ^2.0.5  # Don't do this!
```

✅ **CORRECT:**
The `shorebird_code_push` package is automatically injected by Shorebird CLI during release builds. It's not available on pub.dev.

## 🚀 Publishing Workflow

### 1. Create a Release (New Version)

When you need to publish a **new version** to the Play Store:

```bash
# Update version in pubspec.yaml first (e.g., 1.0.0+1 → 1.0.1+2)

# Build and publish release
shorebird release android

# This creates:
# - build/app/outputs/bundle/release/app-release.aab
# - Uploads release to Shorebird servers
```

Then upload the AAB to Google Play Console.

### 2. Create a Patch (OTA Update)

When you need to push a **quick fix** without Play Store review:

```bash
# Make your code changes

# Create and publish patch
shorebird patch android --release-version=1.0.0+1

# This creates a small patch (usually < 300 KB) that will be
# automatically downloaded by users running that release version
```

**Important:** Patches can only contain Dart code changes. Native code changes require a new release.

## 📱 Testing Updates

### Test in Release Mode

```bash
# Build a release APK for testing
flutter build apk --release

# Or use Shorebird preview
shorebird preview
```

### Simulate Update Flow

1. Install release build on device
2. Create a patch with code changes
3. Restart the app
4. The app should detect and download the patch
5. After another restart, the patch will be applied

## 🛠️ Commands Reference

```bash
# Check Shorebird status
shorebird doctor

# View all releases
shorebird releases list

# View patches for a release
shorebird patches list --release-version=1.0.0+1

# View app info
shorebird apps list

# Login to Shorebird
shorebird login

# Logout
shorebird logout
```

## 📊 Current Build Info

- **App ID:** 0313e70d-2162-4191-bcc5-75abb03f3cdc
- **Latest Release:** 1.0.0+1
- **Latest Patch:** Patch 1
- **Flutter Version:** 3.35.7
- **Platforms:** Android (arm32, arm64, x86_64)

## 🔧 Troubleshooting

### "Shorebird not available" in Debug Mode
✅ This is expected! Shorebird only works in release builds.

### Import Error: `package:shorebird_code_push`
✅ Remove it from pubspec.yaml. Shorebird injects it automatically.

### Patch Not Downloading
1. Make sure you're testing on a release build
2. Check internet connection
3. Verify patch was published: `shorebird patches list`
4. Check app logs for update checker messages

### "No update available" After Publishing Patch
1. Completely close and restart the app
2. Wait a few minutes for CDN propagation
3. Check the patch is for the correct release version

## 📁 Project Structure

```
lib/
├── core/
│   ├── services/
│   │   └── shorebird_service.dart      # Shorebird integration service
│   └── widgets/
│       └── update_checker_widget.dart  # Auto-update UI widget
└── main.dart                            # Initializes Shorebird on app start
```

## 🎨 UI Features

### Update Dialog
- Shows when new patch is available
- User can choose "Update Now" or "Later"
- Material Design 3 styled
- Theme-aware (light/dark mode)

### Download Progress
- Shows loading indicator while downloading
- Informs user to restart after download

## 📝 Best Practices

1. **Always test patches** before publishing to production
2. **Use patches for** bug fixes, small features, UI tweaks
3. **Use releases for** native code changes, major versions
4. **Version naming:**
   - Increment patch number (+1) for patches
   - Increment version (1.0.1) for new releases
5. **Keep patches small** - aim for < 500 KB
6. **Document changes** in patch descriptions

## 🔐 Security Notes

- Shorebird.yaml is safe to commit (contains only App ID)
- App ID is public and not a secret
- Shorebird authenticates via your CLI login
- Patches are served over HTTPS
- Code signing is handled by Shorebird

## 📚 Resources

- [Shorebird Documentation](https://docs.shorebird.dev)
- [Shorebird Console](https://console.shorebird.dev)
- [Flutter Documentation](https://flutter.dev)

## 🆘 Support

If you encounter issues:
1. Check Shorebird logs: `shorebird doctor`
2. Visit [Shorebird Discord](https://discord.gg/shorebird)
3. Check [GitHub Issues](https://github.com/shorebirdtech/shorebird/issues)

---

**Last Updated:** November 8, 2025
**Maintained By:** TioNova Team

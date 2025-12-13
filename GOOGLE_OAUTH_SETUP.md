# Google OAuth Configuration for Firebase Hosting

## Your Firebase Hosting Details

- **Project ID**: `tionova-c566b`
- **Firebase Auth Domain**: `tionova-c566b.firebaseapp.com`
- **Hosting URL**: `https://tionova-c566b.web.app`
- **Alternate Hosting URL**: `https://tionova-c566b.firebaseapp.com`

---

## Step 1: Configure Authorized Domains in Firebase Console

### Method A: Using Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **tionova-c566b** project
3. Navigate to **Authentication** → **Settings** tab
4. Scroll to **Authorized domains**
5. Click **+ Add domain**
6. Add the following URLs:
   - `tionova-c566b.web.app`
   - `tionova-c566b.firebaseapp.com`
   - `localhost:8000` (for local development)
   - `localhost:3000` (for local development)

✅ **These are automatically added by Firebase**

---

## Step 2: Configure Google OAuth in Google Cloud Console

### Prerequisites
- Google Cloud Project linked to Firebase (automatically created)
- Admin access to Google Cloud Console

### Steps:

1. **Go to Google Cloud Console**
   - https://console.cloud.google.com
   - Select **tionova-c566b** project

2. **Navigate to OAuth Consent Screen**
   - Left sidebar → **APIs & Services**
   - Click **OAuth consent screen**
   - Select **External** (or **Internal** if private)
   - Click **Create**

3. **Fill OAuth Consent Form**
   - **App name**: `TioNova`
   - **User support email**: Your email
   - **App logo**: (Optional) Add TioNova logo
   - **App domain**: `tionova-c566b.firebaseapp.com`
   - **Authorized domains**: 
     - `tionova-c566b.firebaseapp.com`
     - `tionova-c566b.web.app`
   - **Developer contact info**: Your email
   - Click **Save and Continue**

4. **Configure Scopes**
   - Click **Add or Remove Scopes**
   - Select:
     - `email`
     - `openid`
     - `profile`
   - Click **Update** → **Save and Continue**

5. **Add Test Users** (if using External)
   - Add your email
   - Add any test user emails
   - Click **Save and Continue**

6. **Review & Finish**
   - Click **Back to Dashboard**

---

## Step 3: Create OAuth 2.0 Credentials

### For Web Application:

1. Go back to **APIs & Services**
2. Click **Credentials** (left sidebar)
3. Click **+ Create Credentials**
4. Select **OAuth 2.0 Client ID**
5. Choose **Web application**
6. Fill in the form:

   **Name**: `TioNova Web`

   **Authorized JavaScript origins** (Add all):
   ```
   https://tionova-c566b.firebaseapp.com
   https://tionova-c566b.web.app
   https://localhost:3000
   http://localhost:3000
   http://localhost:8000
   ```

   **Authorized redirect URIs** (Add all):
   ```
   https://tionova-c566b.firebaseapp.com/__/auth/handler
   https://tionova-c566b.web.app/__/auth/handler
   https://tionova-c566b.firebaseapp.com/
   https://tionova-c566b.web.app/
   http://localhost:3000
   http://localhost:8000
   ```

7. Click **Create**
8. Copy the **Client ID** and **Client Secret**
   - Note: You can use these for additional integrations if needed

---

## Step 4: Enable Google Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **tionova-c566b** project
3. Navigate to **Authentication** → **Sign-in method**
4. Click **Google**
5. Toggle **Enable**
6. Select your **Project support email**
7. Click **Save**

✅ **Google Sign-In is now enabled!**

---

## Step 5: Configure Web App Settings

### In Firebase Console:

1. Go to **Project Settings** → **Your apps**
2. Find your **Web** app (if not listed, click **+ Add app**)
3. Under **SDK setup and configuration**, ensure you have:

```dart
// Already in your firebase_options.dart
FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyCZFhlwpe8_nwoRejZSmWUNq6sYSL_heyQ',
  appId: '1:187048592726:web:34d266cdb991ecb89402f7',
  messagingSenderId: '187048592726',
  projectId: 'tionova-c566b',
  authDomain: 'tionova-c566b.firebaseapp.com',
  databaseURL: 'https://tionova-c566b-default-rtdb.europe-west1.firebasedatabase.app',
  storageBucket: 'tionova-c566b.firebasestorage.app',
  measurementId: 'G-QXM87T79Z7',
);
```

---

## Step 6: Verify in Your Flutter Code

Your Google Sign-In implementation should work with this configuration:

```dart
// In your auth service or cubit
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Start Google Sign-In flow
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    // Get Google authentication
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Google Sign-In Error: $e');
    return null;
  }
}
```

---

## Security Rules Configuration

### Firestore Security Rules:

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Public data
    match /challenges/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Realtime Database Rules:

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    "users": {
      "$uid": {
        ".read": "auth.uid === $uid",
        ".write": "auth.uid === $uid"
      }
    },
    "challenges": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

---

## Testing Before Deployment

### Local Testing:

```bash
# Build web version
flutter build web --release

# Test locally (requires firebase-tools)
firebase serve --only hosting
```

Visit `http://localhost:5000` and test Google Sign-In flow.

### Post-Deployment Testing:

1. Visit `https://tionova-c566b.web.app`
2. Click Google Sign-In button
3. You should be redirected to Google login
4. After authentication, redirect back to app
5. Verify user is logged in

---

## Troubleshooting

### Issue: "Redirect URI mismatch"
**Solution**: Ensure all redirect URIs from Step 3 are added in Google Cloud Console

### Issue: "Invalid OAuth client"
**Solution**: Verify OAuth consent screen is configured before creating credentials

### Issue: "App not verified" warning
**Solution**: This is normal for External consent screen. Click "Continue" to proceed.

### Issue: "User hasn't authorized app"
**Solution**: Make sure your email is in Test Users list (if External consent screen)

### Issue: Google Sign-In not working on deployed app
**Solutions**:
1. Check that `tionova-c566b.web.app` is in authorized domains
2. Verify Google Sign-In is enabled in Firebase Console
3. Clear browser cache and cookies
4. Check browser console for specific errors

### Issue: Can't find OAuth Client ID
**Solution**: You likely don't need the Client ID for Firebase Google Sign-In (Firebase handles this automatically)

---

## Additional Authorized URLs

If you use custom domains later, add them:

1. Firebase Console → Authentication → Authorized domains
2. Add your custom domain (e.g., `www.tionova.com`)
3. Add same domain to Google Cloud Console OAuth configuration

---

## Checklist

✅ Firebase Console - Authentication - Sign-in methods (Google enabled)
✅ Firebase Console - Authorized domains configured
✅ Google Cloud Console - OAuth consent screen configured
✅ Google Cloud Console - OAuth 2.0 credentials created
✅ Google Cloud Console - Authorized redirect URIs added
✅ Firebase_options.dart has web configuration
✅ flutter_test web build locally
✅ Deploy with `firebase deploy --only hosting`

---

## Summary of URLs

| Type | URL |
|------|-----|
| **Main Hosting** | `https://tionova-c566b.web.app` |
| **Alt Hosting** | `https://tionova-c566b.firebaseapp.com` |
| **Auth Domain** | `tionova-c566b.firebaseapp.com` |
| **Firebase Console** | `https://console.firebase.google.com/project/tionova-c566b` |
| **Google Cloud Console** | `https://console.cloud.google.com/project/tionova-c566b` |

---

**Your setup is complete!** Google Sign-In is now configured for your Firebase Hosting deployment.

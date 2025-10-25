# Firebase Realtime Database Security Rules for Live Challenges

## 🔥 Issue: Participants Cannot See Each Other in Lobby

### Problem
- ✅ Owner CAN see all participants (working)
- ❌ Participants CANNOT see each other in waiting lobby (not working)

### Root Cause
Firebase Realtime Database **Security Rules** are blocking read access for participants.

---

## 📋 Required Firebase Security Rules

Copy and paste these rules into your Firebase Realtime Database Rules:

### Option 1: Open Rules (For Development/Testing)
```json
{
  "rules": {
    "liveChallenges": {
      "$challengeCode": {
        ".read": "auth != null",
        ".write": "auth != null",
        "participants": {
          ".read": "auth != null",
          ".write": "auth != null"
        },
        "meta": {
          ".read": "auth != null",
          ".write": "data.child('ownerId').val() === auth.uid || !data.exists()"
        },
        "questions": {
          ".read": "auth != null",
          ".write": "data.parent().child('meta/ownerId').val() === auth.uid"
        },
        "answers": {
          ".read": "auth != null",
          ".write": "auth != null"
        },
        "current": {
          ".read": "auth != null",
          ".write": "data.parent().child('meta/ownerId').val() === auth.uid"
        },
        "rankings": {
          ".read": "auth != null",
          ".write": "data.parent().child('meta/ownerId').val() === auth.uid"
        }
      }
    }
  }
}
```

### Option 2: Secure Rules (For Production)
```json
{
  "rules": {
    "liveChallenges": {
      "$challengeCode": {
        // Anyone authenticated can read challenge data
        ".read": "auth != null && (
          root.child('liveChallenges/' + $challengeCode + '/meta/ownerId').val() === auth.uid ||
          root.child('liveChallenges/' + $challengeCode + '/participants/' + auth.uid).exists()
        )",
        
        "participants": {
          // All participants can read the participants list
          ".read": "auth != null",
          
          // Only allow users to write their own participant data
          "$userId": {
            ".write": "auth.uid === $userId"
          }
        },
        
        "meta": {
          // All participants can read meta
          ".read": "auth != null",
          
          // Only owner can write meta (except initial creation)
          ".write": "auth.uid === newData.child('ownerId').val() || !data.exists()"
        },
        
        "questions": {
          // All participants can read questions
          ".read": "auth != null",
          
          // Only owner can write questions
          ".write": "auth.uid === root.child('liveChallenges/' + $challengeCode + '/meta/ownerId').val()"
        },
        
        "answers": {
          // All participants can read all answers
          ".read": "auth != null",
          
          "$questionIndex": {
            "$userId": {
              // Users can only write their own answers
              ".write": "auth.uid === $userId"
            }
          }
        },
        
        "current": {
          // All participants can read current question
          ".read": "auth != null",
          
          // Only owner can update current question
          ".write": "auth.uid === root.child('liveChallenges/' + $challengeCode + '/meta/ownerId').val()"
        },
        
        "rankings": {
          // All participants can read rankings
          ".read": "auth != null",
          
          // Only owner or system can write rankings
          ".write": "auth.uid === root.child('liveChallenges/' + $challengeCode + '/meta/ownerId').val()"
        }
      }
    }
  }
}
```

### Option 3: Super Simple (Testing Only - Very Insecure!)
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

---

## 🛠️ How to Apply These Rules

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **tionova-c566b**

### Step 2: Navigate to Realtime Database
1. Click on **Realtime Database** in the left sidebar
2. Click on the **Rules** tab

### Step 3: Update Rules
1. **Delete** the existing rules
2. **Copy** one of the rule sets above (recommend Option 2 for production)
3. **Paste** into the rules editor
4. Click **Publish**

### Step 4: Test the Rules
After publishing, use the **Rules Playground** in Firebase Console:
- Select "Simulate" as **Read**
- Location: `/liveChallenges/F3C277/participants`
- Auth: Use your test user's UID
- Click "Run"
- Should show **✅ Allowed**

---

## 🔍 Debugging Steps

### 1. Check Console Logs

**If Working (Owner & Participants see each other):**
```
WaitingLobbyScreen - Challenge code: F3C277
WaitingLobbyScreen - Setting up participants listener at: liveChallenges/F3C277/participants
WaitingLobbyScreen - Participants event received
WaitingLobbyScreen - Snapshot exists: true
WaitingLobbyScreen - Processing 2 participants
WaitingLobbyScreen - Username: Owner, Active: true
WaitingLobbyScreen - Username: Player, Active: true
WaitingLobbyScreen - Participants updated: 2 active, names: [Owner, Player]
```

**If Permission Denied:**
```
WaitingLobbyScreen - Challenge code: F3C277
WaitingLobbyScreen - Setting up participants listener at: liveChallenges/F3C277/participants
WaitingLobbyScreen - Firebase listener ERROR: [firebase_database/permission-denied] ...
WaitingLobbyScreen - Error type: FirebaseException
WaitingLobbyScreen - PERMISSION DENIED! Check Firebase Security Rules!
```

**If No Data:**
```
WaitingLobbyScreen - Challenge code: F3C277
WaitingLobbyScreen - Setting up participants listener at: liveChallenges/F3C277/participants
WaitingLobbyScreen - Participants event received
WaitingLobbyScreen - Snapshot exists: false
WaitingLobbyScreen - No participants data found
```

### 2. Verify Authentication
Make sure users are authenticated before joining:
```dart
final authState = context.read<AuthCubit>().state;
if (authState is AuthSuccess) {
  print('User authenticated with token: ${authState.token}');
  print('User ID: ${authState.user.id}'); // Should match Firebase UID
}
```

### 3. Check Firebase Data Structure
In Firebase Console → Realtime Database → Data:
```
liveChallenges/
  F3C277/
    participants/
      68e8aa801a96a7b6c56b3beb/  ← Owner UID
        active: true
        username: "Owner"
      68ea8011268fe6f8f5d798c9/  ← Participant UID
        active: true
        username: "Player"
```

---

## 🎯 Expected Behavior After Fix

### Owner (CreateChallengeScreen)
✅ Should see:
- "2 players joined and ready"
- "Participants in Lobby" section with badges: [● Owner] [● Player]

### Participant (ChallengeWaitingLobbyScreen)
✅ Should see:
- "2 players ●"
- "Players in Lobby" section with badges: [● Owner] [● Player]

### Both Should See Same List
- Owner badge: "Owner"
- Participant badge: "Player"
- Real-time updates when anyone joins/leaves

---

## 🚨 Common Issues & Solutions

### Issue 1: "Permission Denied" Error
**Solution:** Apply the Firebase Security Rules above (Option 1 or 2)

### Issue 2: Participants List is Empty
**Possible Causes:**
1. Firebase database URL not configured → ✅ Already fixed in firebase_options.dart
2. Challenge code mismatch
3. Participant data not written to Firebase after joining
4. Network connectivity issues

**Solution:** Check console logs for the exact error

### Issue 3: Owner Sees Participants, But Participants Don't
**Cause:** Owner likely has different permissions than participants
**Solution:** Use Option 2 rules that grant equal read access to all authenticated users

### Issue 4: Data Shows in Console But Not in UI
**Possible Causes:**
1. `_participants` list not being populated correctly
2. `activeParticipants.isEmpty` condition preventing UI render
3. Widget not rebuilding after setState

**Solution:** Check logs to see if `setState` is being called with correct data

---

## 📱 Testing Checklist

### Test Scenario 1: Owner Creates Challenge
1. Owner creates challenge with code F3C277
2. Owner should see "1 players" (themselves)
3. Owner should see their own name in "Participants in Lobby"

### Test Scenario 2: Participant Joins
1. Participant enters code F3C277
2. Participant navigates to waiting lobby
3. Participant should see "2 players"
4. Participant should see both "Owner" and "Player" badges
5. Owner screen should auto-update to show "2 players" and both badges

### Test Scenario 3: Multiple Participants
1. Participant 2 joins with code F3C277
2. Both owner and all participants should see "3 players"
3. All should see three badges: [● Owner] [● Player] [● Player2]

### Test Scenario 4: Participant Leaves
1. Participant closes app or leaves lobby
2. Firebase should set `active: false` for that user
3. All remaining participants should see updated count
4. Inactive user should not show in badges list

---

## 🔧 Quick Fix Commands

### Restart App Completely
```bash
# Stop the app
flutter clean

# Reinstall dependencies
flutter pub get

# Run again
flutter run
```

### Check Firebase Connection
Add this to your main.dart after Firebase.initializeApp():
```dart
final ref = FirebaseDatabase.instance.ref('test');
await ref.set({'timestamp': DateTime.now().millisecondsSinceEpoch});
print('Firebase write test successful');
```

---

## ✅ Summary

**Most Likely Solution:** Apply Firebase Security Rules (Option 2 recommended)

**Steps:**
1. Go to Firebase Console
2. Navigate to Realtime Database → Rules
3. Replace rules with Option 2 from above
4. Click Publish
5. Restart your Flutter app completely
6. Test both owner and participant flows
7. Check console logs for any errors

**The error handling we added will help identify if it's a permission issue!** 🎯

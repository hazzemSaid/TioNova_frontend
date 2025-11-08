# Quick Start Testing Guide - Live Challenge Feature

## Prerequisites
1. Backend API must be running and accessible
2. Firebase Realtime Database must be configured
3. GetIt integration completed (see GETIT_INTEGRATION_INSTRUCTIONS.md)
4. At least 2 devices/emulators for full testing

## Quick Test Flow

### 1. Test Single Player Flow
```bash
# Run the app
flutter run

# Steps:
1. Navigate to challenges
2. Join a challenge with a code
3. Observe:
   - Firebase listeners connecting
   - Questions loading
   - Timer counting down
4. Select an answer
5. Click submit
6. Wait for feedback
7. Observe question advancement
8. Complete challenge
```

### 2. Test Polling Service
Check console logs for:
```
LiveQuestionScreen - Starting polling service
ChallengeCubit - Checking if should advance question
LiveQuestionScreen - Polling response: {needsAdvance: false, ...}
```

Should appear every 5 seconds.

### 3. Test Timer Warnings
1. Wait until timer reaches 10 seconds
2. Verify:
   - Sound plays (if enabled)
   - Vibration occurs
   - Timer color changes to red
   - Timer pulses faster

### 4. Test Timeout (No Answer Selected)
1. Don't select any answer
2. Wait for timer to reach 0
3. Verify:
   - Timeout sound plays
   - Vibration occurs
   - "Time's Up!" dialog appears
   - Submit button becomes disabled
   - Options become unselectable
4. Background polling (every 5 seconds) will:
   - Call `checkAndAdvance()` API
   - Backend marks user as unanswered (`answer: null`)
   - Question advances when all active players answered or time expired
   - User sees "Waiting for other players..." state
5. When question advances:
   - Next question loads automatically
   - Timer resets to 30 seconds
   - New options become selectable

### 5. Test Answer Feedback
1. Submit a correct answer
2. Verify:
   - Success sound plays
   - Double vibration pattern
   - Green feedback UI
   - Rank displayed

3. Submit an incorrect answer
4. Verify:
   - Error sound plays
   - Single heavy vibration
   - Red feedback UI
   - Correct answer shown

### 6. Test Real-time Updates & Reconnection
With 2+ devices:
1. **Initial Join:**
   - Device A and B join same challenge
   - Both appear in participant list
   - Owner starts challenge
   - Both see questions simultaneously

2. **Answer Submission:**
   - Device A submits answer
   - Device B sees "X/Y players answered" update
   - When all answer, both advance to next question

3. **Disconnection (Device A):**
   - Device A closes app or loses network
   - Device A is marked as `active: false` in participants
   - Device B continues normally (game doesn't freeze)
   - Only active players count for "all answered" check

4. **Reconnection (Device A):**
   - Device A reopens app and joins with same challenge code
   - Device A is marked as `active: true` again
   - Device A resumes from current question with preserved score
   - Device A's previous answers are still recorded
   - Both devices now see Device A as active again

### 7. Test Leaderboard
1. During challenge, tap "Live Scoreboard"
2. Verify:
   - Shows all participants
   - Scores are updated
   - Ranks are correct
   - Top 3 have medal colors

### 8. Test Challenge Completion
1. Complete all questions
2. Verify:
   - Auto-navigate to results screen
   - Final score displayed
   - Rank shown
   - Leaderboard visible
   - Celebration for winners

## Console Debug Messages to Watch

### Initialization
```
LiveQuestionScreen - initState for challenge: ABC123
LiveQuestionScreen - Setting up Firebase listeners
LiveQuestionScreen - Starting polling service
```

### Question Updates
```
LiveQuestionScreen - Questions event received
LiveQuestionScreen - Parsed 3 questions
LiveQuestionScreen - Current question set: What is...?
```

### Timer
```
LiveQuestionScreen - Starting question timer
LiveQuestionScreen - Elapsed: 5 seconds
LiveQuestionScreen - Time remaining: 25 seconds
LiveQuestionScreen - Timer tick: 10 seconds remaining (WARNING)
```

### Answer Submission
```
LiveQuestionScreen - Submitting answer: B
ChallengeCubit - Submitting answer: "B" for question 0
ChallengeCubit - Answer submitted successfully
LiveQuestionScreen - Answer submitted, waiting for other players...
```

### Timeout (No Answer)
```
LiveQuestionScreen - Timer expired!
LiveQuestionScreen - No answer selected, showing timeout dialog
LiveQuestionScreen - User did not submit answer
(Polling will handle marking as unanswered on backend)
```

### Reconnection
```
ChallengeCubit - Joining challenge with code: ABC123
DataSource - Join response: { isReconnection: true, currentScore: 5 }
ChallengeCubit - Reconnected successfully, resuming from question 2
LiveQuestionScreen - Restoring state for reconnected user
```

### Polling
```
ChallengePollingService - Executing poll...
ChallengeCubit - Checking if should advance question
ChallengeCubit - Check advance response: {needsAdvance: true, advanced: false}
```

### Polling - Time Expired (No User Action)
```
ChallengePollingService - Executing poll...
ChallengeCubit - Check advance response: {needsAdvance: true, timeExpired: true}
Backend - Marking unanswered participants...
Backend - Auto-advancing to next question
ChallengeCubit - Check advance response: {needsAdvance: true, advanced: true, currentIndex: 3}
LiveQuestionScreen - Question advanced by backend due to timeout
```

### Advancement
```
LiveQuestionScreen - Index changed from 0 to 1
LiveQuestionScreen - Showing question 2/3
```

### Completion
```
LiveQuestionScreen - Status changed to: completed
LiveQuestionScreen - Challenge completed! Navigating to results...
```

## Common Issues & Solutions

### Issue: Polling not starting
**Solution:** Check that auth state is `AuthSuccess` and token is valid

### Issue: Timer not syncing
**Solution:** Verify Firebase path: `liveChallenges/{code}/current/startTime`

### Issue: Questions not loading
**Solution:** Check Firebase path: `liveChallenges/{code}/questions`

### Issue: Rank not showing in feedback
**Solution:** Ensure leaderboard listener is active and receiving data

### Issue: No sound/vibration
**Solution:** 
- Check device settings
- Verify services are enabled
- Test on physical device (emulator may have limitations)

### Issue: GetIt errors
**Solution:** See GETIT_INTEGRATION_INSTRUCTIONS.md

## Performance Checks

Monitor for:
- [ ] No UI jank during animations
- [ ] Smooth timer countdown
- [ ] Quick response to button taps (<100ms)
- [ ] Firebase updates within 1 second
- [ ] Polling doesn't block UI
- [ ] Memory usage stays stable
- [ ] No listener leaks (check dispose logs)

## Network Testing

### Good Connection
- Everything should work smoothly

### Slow Connection (3G)
- Polling may be delayed but should work
- Firebase should buffer updates
- UI should remain responsive

### No Connection
- Current limitation: Will show errors
- TODO: Implement offline queueing

### Reconnection
- TODO: Implement rejoin flow
- Currently: User needs to manually rejoin

## Multi-Device Testing Scenarios

### Scenario 1: Everyone answers quickly
1. All players submit within 10 seconds
2. Question advances immediately after last player
3. All see feedback simultaneously

### Scenario 2: One player is slow
1. 3/4 players answer quickly
2. Last player has 20 seconds left
3. Others see "3/4 players answered"
4. When 4th answers, all advance

### Scenario 3: Timeout (No Answer)
1. One player doesn't select or submit any answer
2. Their timer expires (reaches 0)
3. Frontend shows "Time's Up!" dialog
4. Submit button becomes disabled
5. Polling service calls `checkAndAdvance()` after timer expires
6. Backend automatically marks them as unanswered:
   ```json
   {
     "answer": null,
     "isCorrect": false,
     "timeExpired": true,
     "autoMarked": true
   }
   ```
7. Challenge advances for everyone when all active players answered OR timer expired
8. Player who didn't answer gets 0 points for that question

### Scenario 4: Reconnection After Disconnect
1. Player A disconnects mid-challenge (closes app)
2. Backend marks Player A as `active: false`
3. Other players continue without freezing
4. Player A reopens app and calls `joinChallenge()` with same code
5. Backend detects existing participant:
   - Sets `active: true`
   - Preserves their score
   - Returns `isReconnection: true` and current question index
6. Player A resumes from current question
7. All previous answers remain recorded

### Scenario 4: Host leaves
1. Host disconnects mid-challenge
2. Challenge should continue
3. Participants can complete
4. (Backend handles this)

## Stress Testing

### High Load
- 10+ participants in one challenge
- Verify Firebase handles concurrent updates
- Check leaderboard updates smoothly

### Rapid Submissions
- All players spam submit button
- Verify no duplicate submissions
- Ensure answer locks after first submit

### Long Challenge
- 50 questions
- Verify memory doesn't grow unbounded
- Check animations stay smooth

## Debugging Tips

### Enable Verbose Logging
Add at top of `main.dart`:
```dart
void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    debugPrintSynchronously('[${DateTime.now()}] $message', wrapWidth: wrapWidth);
  };
  
  runApp(MyApp());
}
```

### Firebase Debugging
Open Firebase Console → Realtime Database → View live data updates

### Network Debugging
Use Charles Proxy or Proxyman to inspect HTTP requests

### Device Logs
```bash
# Android
adb logcat | grep -i flutter

# iOS
idevicesyslog | grep -i flutter
```

## Success Criteria

✅ All features work without errors
✅ Smooth 60fps UI throughout
✅ No memory leaks (check with Dart DevTools)
✅ Accurate timer synchronization
✅ Real-time updates work reliably
✅ Sound and vibration feedback works
✅ Animations are smooth and professional
✅ Multiple players can join and play together
✅ Challenge completes and shows results correctly
✅ Timeout handling works (no answer = auto-marked by backend)
✅ Reconnection preserves score and resumes from current question
✅ Inactive players don't block game progression

## Important Behavior Notes

### ⏱️ Timeout Handling (No Answer Submitted)
**Frontend Behavior:**
- Timer counts down to 0
- Submit button becomes disabled
- Options become unselectable
- User sees "Time's Up!" dialog
- **No API call is made for "no answer"**

**Backend Behavior:**
- Polling service (every 5 seconds) calls `checkAndAdvance()`
- Backend detects timer expired
- Backend automatically marks unanswered participants:
  ```json
  {
    "answer": null,
    "isCorrect": false,
    "timeExpired": true,
    "autoMarked": true
  }
  ```
- Question auto-advances when:
  - All active players answered, OR
  - Timer expired (30 seconds)

**Key Point:** User doesn't need to submit anything. Backend handles marking unanswered participants automatically.

### 🔄 Reconnection Handling
**Disconnect:**
- User closes app or loses network
- `disconnectChallenge()` API called (if graceful)
- User marked as `active: false`
- Score and answers preserved
- Other players continue (no freezing)

**Reconnect:**
- User reopens app and calls `joinChallenge()` with same code
- Backend detects existing participant
- Sets `active: true`
- Returns:
  ```json
  {
    "isReconnection": true,
    "currentScore": 5,
    "currentIndex": 2
  }
  ```
- Frontend restores user to current question
- All previous answers remain intact

**Key Point:** Reconnection is seamless - users never lose their progress or score.

### 👥 Inactive Player Handling
- Only **active players** (`active !== false`) count for:
  - "All players answered" check
  - Starting challenge (minimum 2 active players)
  - Question advancement logic
- Inactive players:
  - Remain in participants list
  - Can reconnect anytime
  - Don't block game progression
  - Score is preserved

## Next Steps After Testing

1. Fix any bugs found
2. Create waiting lobby screen
3. Create create/join screen
4. Add reconnection logic
5. Add network error handling
6. Implement offline support
7. Add analytics tracking
8. Production testing with real users

---

## Quick Commands Reference

```bash
# Run app
flutter run

# Run with logs
flutter run -v

# Clean build
flutter clean && flutter pub get && flutter run

# Check for errors
flutter analyze

# Run specific device
flutter run -d <device_id>

# Hot reload
r (in terminal)

# Hot restart
R (in terminal)

# Quit
q (in terminal)
```

---

**Happy Testing! 🚀**

For issues, check:
1. Console logs
2. Firebase Realtime Database console
3. Backend API logs
4. LIVE_CHALLENGE_IMPLEMENTATION.md for architecture details

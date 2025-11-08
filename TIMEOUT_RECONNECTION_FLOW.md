# Quick Reference: Timeout & Reconnection Flow

## 🚫 Timeout Flow (User Doesn't Answer)

### Frontend (Flutter)
```
1. Timer starts at 30 seconds
   ↓
2. User sees countdown but doesn't select answer
   ↓
3. Timer reaches 0
   ↓
4. Frontend Actions:
   - Disable submit button
   - Disable option buttons
   - Show "Time's Up!" dialog
   - NO API call made
   ↓
5. Polling continues (every 5 seconds)
   ↓
6. Poll calls: checkAndAdvance()
```

### Backend (Node.js + Firebase)
```
1. checkAndAdvance() receives request
   ↓
2. Calculate time elapsed: now - startTime
   ↓
3. If elapsed > 30 seconds:
   ↓
4. Call markUnansweredParticipants()
   ↓
5. For each active participant without answer:
   - Write to Firebase:
     answers[currentIndex][userId] = {
       answer: null,
       isCorrect: false,
       timeExpired: true,
       autoMarked: true,
       ts: Date.now()
     }
   ↓
6. Advance to next question or complete
   ↓
7. Return response:
   {
     needsAdvance: true,
     advanced: true,
     currentIndex: next,
     unansweredCount: X
   }
```

### Frontend Receives Response
```
1. Parse response
   ↓
2. If advanced: true
   ↓
3. Load next question
   ↓
4. Reset timer to 30 seconds
   ↓
5. Enable buttons again
   ↓
6. User continues
```

---

## 🔄 Reconnection Flow

### Disconnect
```
Frontend                          Backend                    Firebase
   │                                 │                          │
   │  1. User closes app            │                          │
   │     or loses network            │                          │
   │                                 │                          │
   │  2. Call disconnect API         │                          │
   │  ──────────────────────────────>│                          │
   │                                 │                          │
   │                                 │  3. Mark inactive        │
   │                                 │  ───────────────────────>│
   │                                 │     participants[userId]  │
   │                                 │       .active = false     │
   │                                 │       .disconnectedAt =   │
   │                                 │        Date.now()         │
   │                                 │                          │
   │  4. 200 OK                      │                          │
   │  <──────────────────────────────│                          │
   │                                 │                          │
   │  5. Save challenge code         │                          │
   │     to SharedPreferences        │                          │
   │                                 │                          │
```

### Reconnect
```
Frontend                          Backend                    Firebase
   │                                 │                          │
   │  1. User reopens app            │                          │
   │                                 │                          │
   │  2. Read saved challenge        │                          │
   │     code from storage           │                          │
   │                                 │                          │
   │  3. Show "Rejoin?" dialog       │                          │
   │     User clicks "Yes"           │                          │
   │                                 │                          │
   │  4. Call joinChallenge()        │                          │
   │  ──────────────────────────────>│                          │
   │     { challengeCode }           │                          │
   │                                 │                          │
   │                                 │  5. Check if user exists │
   │                                 │  <───────────────────────│
   │                                 │     participants[userId] │
   │                                 │       exists? YES        │
   │                                 │                          │
   │                                 │  6. Update participant   │
   │                                 │  ───────────────────────>│
   │                                 │     .active = true       │
   │                                 │     .rejoinedAt =        │
   │                                 │      Date.now()          │
   │                                 │                          │
   │                                 │  7. Fetch current state  │
   │                                 │  <───────────────────────│
   │                                 │     currentIndex: 2      │
   │                                 │     score: 5             │
   │                                 │                          │
   │  8. Response with               │                          │
   │     reconnection data           │                          │
   │  <──────────────────────────────│                          │
   │     {                           │                          │
   │       success: true,            │                          │
   │       isReconnection: true,     │                          │
   │       currentScore: 5,          │                          │
   │       currentIndex: 2           │                          │
   │     }                           │                          │
   │                                 │                          │
   │  9. Restore UI state:           │                          │
   │     - Load question 2           │                          │
   │     - Show score: 5             │                          │
   │     - Start timer               │                          │
   │     - Resume polling            │                          │
   │                                 │                          │
```

---

## 📊 Data Structures

### Firebase: Participant Entry
```json
{
  "participants": {
    "userId123": {
      "userId": "userId123",
      "username": "JohnDoe",
      "score": 5,
      "active": true,              // false when disconnected
      "joinedAt": 1234567890,
      "disconnectedAt": 1234568000, // when they left (optional)
      "rejoinedAt": 1234569000      // when they came back (optional)
    }
  }
}
```

### Firebase: Answers Entry (Timeout Case)
```json
{
  "answers": {
    "0": {  // Question index
      "userId123": {
        "answer": null,           // No answer selected
        "isCorrect": false,
        "ts": 1234567920,
        "timeExpired": true,      // Timer ran out
        "autoMarked": true        // System marked, not user submitted
      },
      "userId456": {
        "answer": "b",
        "isCorrect": true,
        "ts": 1234567905
      }
    }
  }
}
```

---

## 🎯 Key Implementation Points

### Frontend (Flutter)
1. **NO API call on timeout** - Just show UI feedback
2. **Polling handles everything** - 5-second interval
3. **Parse `checkAndAdvance()` response** - Update UI based on `advanced` flag
4. **Save challenge code** - SharedPreferences on disconnect
5. **Rejoin dialog** - Show on app resume if code exists
6. **Restore state** - Use `isReconnection` and `currentIndex` from API

### Backend (Node.js)
1. **Time validation** - Check `Date.now() - startTime > 30000`
2. **Only active participants** - Filter `participants[uid]?.active !== false`
3. **Auto-mark unanswered** - Loop through active participants without answers
4. **Preserve on disconnect** - Set `active: false`, keep score and answers
5. **Detect reconnection** - Check if userId already exists in participants
6. **Return appropriate flags** - `isReconnection`, `currentScore`, `currentIndex`

---

## ✅ Testing Checklist

- [ ] User doesn't answer → Timer expires → Polling marks as unanswered → Game advances
- [ ] User disconnects → Marked inactive → Other players continue
- [ ] User reconnects → Marked active → Resumes from current question with score intact
- [ ] Multiple timeouts → All unanswered users marked correctly
- [ ] Mixed scenario → Some answer, some timeout, game advances correctly
- [ ] Network loss → Graceful disconnect → Successful reconnect
- [ ] App killed → Reconnect on restart → State restored

---

## 🔧 Troubleshooting

### Issue: Users not marked on timeout
**Check:**
- Polling is running (every 5 seconds)
- `checkAndAdvance()` being called
- Backend calculates time correctly
- `markUnansweredParticipants()` executing

### Issue: Reconnection not working
**Check:**
- Challenge code saved correctly
- `joinChallenge()` detecting existing user
- `active` flag being set to `true`
- Response includes `isReconnection: true`

### Issue: Game freezing waiting for disconnected player
**Check:**
- Backend filtering: `participants[uid]?.active !== false`
- Only counting active players in "all answered" logic
- Disconnected users not blocking advancement

---

**Remember:** The system is designed to be resilient and fair - timeouts are handled gracefully, and reconnections are seamless! 🚀

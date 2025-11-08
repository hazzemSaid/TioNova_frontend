# Live Challenge Implementation Checklist

Use this checklist to verify your implementation against the Firebase Realtime guide.

## 🎯 Firebase Listeners

- [x] `questions` - Full question list
- [x] `current/index` - Question index changes
- [x] `current/startTime` - Timer start sync
- [ ] `current/endTime` - **MISSING** - Canonical end time from server
- [x] `meta/status` - Challenge lifecycle (waiting/in-progress/completed)
- [ ] `meta` (full object) - **PARTIAL** - Only status, not timestamps
- [x] `rankings` - Live leaderboard updates
- [x] `answers/{questionIndex}` - Per-question answer tracking
- [ ] `participants` - **PARTIAL** - Not filtering by `active` flag

**Score**: 6/9 = 67%

---

## 🔄 Lifecycle Management

- [ ] Attach listeners after join - **DONE via initState**
- [x] Detach listeners on dispose - ✅
- [ ] Call `/disconnect` on app pause - **MISSING**
- [ ] Call `/disconnect` on app background - **MISSING**
- [ ] Call `/join` on app resume - **MISSING**
- [x] Cancel timers on dispose - ✅
- [x] Stop polling on dispose - ✅

**Score**: 3/7 = 43%

---

## ⏱️ Timer & Duration

- [x] Compute from `startTime + duration` - ✅
- [x] Support per-question durations - ✅ (durationSeconds/duration/durationMs)
- [x] Clamp to [0, duration] range - ✅
- [x] Handle ms vs seconds from server - ✅
- [ ] Use server's `endTime` as canonical - **MISSING**
- [x] Show countdown in UI - ✅
- [x] Trigger action at timer=0 - ✅ (dialog)
- [ ] Call check-advance at timer=0 - **PARTIAL** (only via polling)

**Score**: 6/8 = 75%

---

## 📡 API Integration

- [x] POST `/join` - Join challenge
- [x] POST `/answer` - Submit answer
- [x] POST `/check-advance` - Poll for progression
- [ ] POST `/disconnect` - **MISSING** in lifecycle
- [ ] POST `/start` - Owner starts (check if implemented)
- [ ] Handle late answer rejection - **PARTIAL** (no specific UI)

**Score**: 3/6 = 50%

---

## 👥 Participant Tracking

- [x] Count total participants - ✅
- [ ] Filter by `active` flag - **MISSING**
- [ ] Track individual scores - **PARTIAL** (from rankings)
- [ ] Show join/rejoin events - **NO**
- [ ] Display active vs inactive - **NO**
- [x] Update on participant changes - ✅ (via rankings)

**Score**: 2/6 = 33%

---

## 🎨 UI States

- [x] Waiting room - ✅ (via status)
- [x] Question display - ✅
- [x] Timer countdown - ✅
- [x] Answer selection - ✅
- [x] Waiting for others - ✅ (WaitingState widget)
- [x] Feedback (correct/incorrect) - ✅ (FeedbackState widget)
- [x] Leaderboard - ✅ (modal + LeaderboardEntry)
- [x] Completion screen - ✅
- [ ] Reconnection indicator - **MISSING**
- [ ] Late answer badge - **MISSING**

**Score**: 8/10 = 80%

---

## 🧪 Testing

- [x] Unit tests for time normalization - ✅ (25 tests)
- [x] Unit tests for duration parsing - ✅ (20 tests)
- [ ] Widget tests for extracted widgets - **MISSING**
- [ ] Integration test for full flow - **MISSING**
- [ ] Multi-user test scenario - **MANUAL ONLY**

**Score**: 2/5 = 40%

---

## 🏗️ Architecture

- [x] Stateless wrapper - ✅ LiveQuestionScreen
- [x] Stateful body - ✅ LiveQuestionScreenBody
- [x] Extracted widgets - ✅ (8 widgets)
- [x] BLoC state management - ✅
- [x] Service layer - ✅ (Sound, Vibration, Polling)
- [x] Resource cleanup - ✅ (dispose)
- [x] Safe context usage - ✅ (mounted guards, cached refs)
- [x] Animation management - ✅ (4 controllers)

**Score**: 8/8 = 100%

---

## 🐛 Error Handling

- [x] Try-catch for async ops - ✅
- [x] Display error messages - ✅ (SnackBar)
- [x] Handle null values - ✅ (defensive parsing)
- [ ] Retry failed API calls - **NO**
- [ ] Offline detection - **NO**
- [x] Logging for debugging - ✅ (print statements)

**Score**: 4/6 = 67%

---

## ⚡ Auto-Advance Logic

- [x] Poll check-advance every 5s - ✅
- [x] Sync timeRemaining from response - ✅
- [ ] Call check-advance at timer=0 - **PARTIAL** (via poll only)
- [ ] Debounce per question index - **MISSING**
- [x] Handle `needsAdvance` flag - ✅
- [x] Handle `completed` response - ✅

**Score**: 4/6 = 67%

---

## 📊 Overall Compliance Score

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| Firebase Listeners | 67% | 15% | 10.0% |
| Lifecycle Mgmt | 43% | 15% | 6.4% |
| Timer & Duration | 75% | 10% | 7.5% |
| API Integration | 50% | 10% | 5.0% |
| Participant Tracking | 33% | 10% | 3.3% |
| UI States | 80% | 10% | 8.0% |
| Testing | 40% | 10% | 4.0% |
| Architecture | 100% | 10% | 10.0% |
| Error Handling | 67% | 5% | 3.3% |
| Auto-Advance | 67% | 5% | 3.3% |

**Total Weighted Score: 60.8%**

---

## 🎯 Priority Actions (Ranked)

### Critical (Fix Immediately)
1. [ ] Add `current/endTime` listener
2. [ ] Implement disconnect on app pause/background
3. [ ] Call check-advance immediately at timer=0

### High (Fix Before Production)
4. [ ] Filter participants by `active` flag
5. [ ] Implement rejoin on app resume
6. [ ] Handle late answer rejection UI

### Medium (Nice to Have)
7. [ ] Add debounce flag per question for check-advance
8. [ ] Listen to full `meta` object (not just status)
9. [ ] Show reconnection indicator in UI
10. [ ] Add widget tests for new components

### Low (Polish)
11. [ ] Retry logic for failed API calls
12. [ ] Offline mode detection and queue
13. [ ] Structured logging (replace print)
14. [ ] Track detailed participant data

---

## ✅ Quick Validation Commands

```bash
# 1. Run unit tests (should pass)
flutter test test/utils/time_normalization_test.dart

# 2. Check for compile errors
flutter analyze

# 3. Verify no unused imports
dart fix --dry-run

# 4. Build for release (check for warnings)
flutter build apk --release

# 5. Manual test checklist:
#    - Join with 2+ users
#    - One user pauses app (check Firebase active flag)
#    - One user resumes (check score preserved)
#    - Answer question before timer
#    - Let timer expire (check auto-advance within 5s)
#    - Complete challenge (check final rankings)
```

---

## 📝 Files Modified

**Existing Files Enhanced:**
- ✅ `lib/features/challenges/presentation/view/screens/live_question_screen.dart`
  - Refactored to stateless wrapper + body
  - Added time normalization logic
  - Integrated polling service

**New Widgets Created:**
- ✅ `lib/features/challenges/presentation/view/widgets/challenge_header.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/challenge_progress_bar.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/challenge_timer_bar.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/live_question_option_button.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/submit_button.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/waiting_state.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/feedback_state.dart`
- ✅ `lib/features/challenges/presentation/view/widgets/leaderboard_entry.dart`

**Tests Created:**
- ✅ `test/utils/time_normalization_test.dart` (45+ tests passing)

**Documentation Created:**
- ✅ `LIVE_CHALLENGE_IMPLEMENTATION_ANALYSIS.md` (detailed audit)
- ✅ `PRIORITY_FIXES_GUIDE.md` (code snippets)
- ✅ `LIVE_CHALLENGE_SUMMARY.md` (executive summary)
- ✅ `LIVE_CHALLENGE_CHECKLIST.md` (this file)

---

## 🏁 Definition of Done

### Minimum Viable (MVP)
- [ ] All critical actions completed (items 1-3)
- [ ] Unit tests passing
- [ ] No compile errors
- [ ] 2-user test scenario works end-to-end

### Production Ready
- [ ] All high-priority actions completed (items 1-6)
- [ ] Widget tests added
- [ ] Multi-user testing with disconnects
- [ ] Offline handling implemented
- [ ] Compliance score > 85%

### Excellence
- [ ] All medium-priority actions completed
- [ ] Integration tests added
- [ ] Structured logging in place
- [ ] Error recovery with retry
- [ ] Compliance score > 95%

---

**Last Updated**: October 28, 2025  
**Current Status**: 60.8% compliant, strong foundation, clear gaps identified

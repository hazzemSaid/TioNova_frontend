# Priority Fixes Implementation Guide

This guide provides code snippets to address the high-priority gaps identified in the analysis.

## 1. Add `current/endTime` Listener (HIGH)

### Location
`lib/features/challenges/presentation/view/screens/live_question_screen.dart`

### Changes Required

#### A. Add Reference and Subscription
```dart
// In class _LiveQuestionScreenBodyState, add after _currentStartTimeRef:
DatabaseReference? _currentEndTimeRef;
StreamSubscription<DatabaseEvent>? _currentEndTimeSubscription;
```

#### B. Setup Listener in `_setupFirebaseListeners()`
```dart
// After current/startTime listener, add:

// 3.5. Listen to current question end time (canonical from server)
final endTimePath = 'liveChallenges/${widget.challengeCode}/current/endTime';
print('LiveQuestionScreen - Setting up endTime listener at: $endTimePath');
_currentEndTimeRef = database.ref(endTimePath);

_currentEndTimeSubscription = _currentEndTimeRef!.onValue.listen(
  (event) {
    print('LiveQuestionScreen - EndTime event received');
    print('LiveQuestionScreen - EndTime value: ${event.snapshot.value}');

    if (!mounted) return;

    final endTime = event.snapshot.value as int?;
    if (endTime != null) {
      print('LiveQuestionScreen - Using server endTime: $endTime');
      _updateTimerFromEndTime(endTime);
    }
  },
  onError: (error) {
    print('LiveQuestionScreen - EndTime listener ERROR: $error');
  },
);
```

#### C. Add Timer Update Method
```dart
/// Update timer using server's canonical endTime
void _updateTimerFromEndTime(int endTimeMs) {
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final remainingMs = endTimeMs - nowMs;
  final questionDuration = _getQuestionDurationSeconds();
  
  final rawRemaining = (remainingMs / 1000).ceil();
  final newRemaining = rawRemaining.clamp(0, questionDuration);
  
  print('LiveQuestionScreen - Server endTime: $endTimeMs');
  print('LiveQuestionScreen - Time remaining from server: $newRemaining seconds');
  
  if (mounted && _timeRemaining != newRemaining) {
    setState(() {
      _timeRemaining = newRemaining;
    });
  }
}
```

#### D. Dispose New Subscription
```dart
// In dispose(), add:
_currentEndTimeSubscription?.cancel();
```

---

## 2. Implement Disconnect/Reconnect Lifecycle (HIGH)

### A. Add WidgetsBindingObserver Mixin
```dart
class _LiveQuestionScreenBodyState extends State<LiveQuestionScreenBody>
    with TickerProviderStateMixin, WidgetsBindingObserver {
```

### B. Register/Unregister Observer
```dart
@override
void initState() {
  super.initState();
  
  // Add this line:
  WidgetsBinding.instance.addObserver(this);
  
  // ... existing init code
}

@override
void dispose() {
  // Add this line first:
  WidgetsBinding.instance.removeObserver(this);
  
  // ... existing dispose code
}
```

### C. Implement Lifecycle Handler
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  
  print('LiveQuestionScreen - App lifecycle changed to: $state');
  
  switch (state) {
    case AppLifecycleState.paused:
    case AppLifecycleState.detached:
      _handleDisconnect();
      break;
    case AppLifecycleState.resumed:
      _handleReconnect();
      break;
    default:
      break;
  }
}

Future<void> _handleDisconnect() async {
  if (!mounted) return;
  
  print('LiveQuestionScreen - Handling disconnect');
  
  final authState = context.read<AuthCubit>().state;
  if (authState is! AuthSuccess) return;
  
  try {
    await context.read<ChallengeCubit>().disconnectFromChallenge(
      token: authState.token,
      challengeCode: widget.challengeCode,
    );
    print('LiveQuestionScreen - Disconnect successful');
  } catch (e) {
    print('LiveQuestionScreen - Disconnect error: $e');
  }
  
  // Stop polling to conserve resources
  _stopPolling();
}

Future<void> _handleReconnect() async {
  if (!mounted) return;
  
  print('LiveQuestionScreen - Handling reconnect');
  
  final authState = context.read<AuthCubit>().state;
  if (authState is! AuthSuccess) return;
  
  try {
    // Rejoin challenge to reactivate participant
    await context.read<ChallengeCubit>().joinChallenge(
      token: authState.token,
      challengeCode: widget.challengeCode,
    );
    print('LiveQuestionScreen - Reconnect successful');
    
    // Restart polling
    _startPolling();
  } catch (e) {
    print('LiveQuestionScreen - Reconnect error: $e');
    
    if (mounted) {
      final messenger = _scaffoldMessenger ?? ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reconnection failed: ${e.toString()}'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleReconnect,
          ),
        ),
      );
    }
  }
}
```

---

## 3. Call Check-Advance on Timer Expiry (HIGH)

### Changes Required

#### A. Add Debounce Flag
```dart
// In class _LiveQuestionScreenBodyState, add:
int? _lastCheckAdvanceQuestionIndex;
```

#### B. Update Timer Logic in `_startQuestionTimer()`
```dart
// In the timer callback where _timeRemaining <= 0, replace with:

if (_timeRemaining <= 0) {
  print('LiveQuestionScreen - Timer expired!');
  timer.cancel();

  // Play timeout sound
  _soundService.playTimeoutSound();
  _vibrationService.warning();

  // Immediately trigger check-advance (don't wait for polling)
  if (_lastCheckAdvanceQuestionIndex != _currentQuestionIndex) {
    _lastCheckAdvanceQuestionIndex = _currentQuestionIndex;
    _triggerCheckAdvance();
  }

  if (!_hasAnswered) {
    _showTimeoutDialog();
  }
}
```

#### C. Add Trigger Method
```dart
Future<void> _triggerCheckAdvance() async {
  if (!mounted) return;
  
  final authState = context.read<AuthCubit>().state;
  if (authState is! AuthSuccess) {
    print('LiveQuestionScreen - Cannot trigger check-advance: not authenticated');
    return;
  }

  print('LiveQuestionScreen - Triggering check-advance for question $_currentQuestionIndex');

  try {
    final response = await context.read<ChallengeCubit>().checkAndAdvanceQuestion(
      token: authState.token,
      challengeCode: widget.challengeCode,
    );

    if (!mounted) return;

    if (response != null) {
      print('LiveQuestionScreen - Check-advance response: $response');
      
      final needsAdvance = response['needsAdvance'] as bool? ?? false;
      final advanced = response['advanced'] as bool? ?? false;
      final completed = response['completed'] as bool? ?? false;

      if (advanced) {
        print('LiveQuestionScreen - Question advanced by check-advance');
      }
      
      if (completed) {
        print('LiveQuestionScreen - Challenge completed by check-advance');
      }
    }
  } catch (e) {
    print('LiveQuestionScreen - Check-advance error: $e');
  }
}
```

---

## 4. Filter Active Participants (MEDIUM)

### Changes Required

#### A. Add Active Participants Tracking
```dart
// In _updateTotalPlayers(), replace with:

void _updateTotalPlayers() {
  final participantsPath = 'liveChallenges/${widget.challengeCode}/participants';
  FirebaseDatabase.instance.ref(participantsPath).once().then((event) {
    if (!mounted) return;

    final data = event.snapshot.value;
    if (data != null && data is Map) {
      // Filter only active participants (where active != false)
      int activeCount = 0;
      
      data.forEach((key, value) {
        if (value is Map) {
          final isActive = value['active'] as bool? ?? true; // Default to true
          if (isActive) {
            activeCount++;
          }
        }
      });

      setState(() {
        _totalPlayers = activeCount;
      });

      print('LiveQuestionScreen - Total active players: $_totalPlayers');
    }
  });
}
```

#### B. Add Continuous Participants Listener (Optional but Recommended)
```dart
// In _setupFirebaseListeners(), add after rankings listener:

final participantsPath = 'liveChallenges/${widget.challengeCode}/participants';
print('LiveQuestionScreen - Setting up participants listener at: $participantsPath');
DatabaseReference participantsRef = database.ref(participantsPath);

StreamSubscription<DatabaseEvent> participantsSubscription = 
    participantsRef.onValue.listen(
  (event) {
    print('LiveQuestionScreen - Participants event received');

    if (!mounted) return;

    final data = event.snapshot.value;
    if (data != null && data is Map) {
      int activeCount = 0;
      
      data.forEach((key, value) {
        if (value is Map) {
          final isActive = value['active'] as bool? ?? true;
          if (isActive) {
            activeCount++;
          }
        }
      });

      setState(() {
        _totalPlayers = activeCount;
      });

      print('LiveQuestionScreen - Active participants updated: $_totalPlayers');
    }
  },
  onError: (error) {
    print('LiveQuestionScreen - Participants listener ERROR: $error');
  },
);

// Store subscription for cleanup
// Add to class: StreamSubscription<DatabaseEvent>? _participantsSubscription;
_participantsSubscription = participantsSubscription;

// In dispose(): _participantsSubscription?.cancel();
```

---

## 5. Backend API Methods (if not already present)

### Check ChallengeCubit for these methods:

```dart
// In challenge_cubit.dart

Future<void> disconnectFromChallenge({
  required String token,
  required String challengeCode,
}) async {
  try {
    // POST /live/challenges/disconnect
    final response = await _repository.disconnectFromChallenge(
      token: token,
      challengeCode: challengeCode,
    );
    
    print('ChallengeCubit - Disconnected from challenge: $challengeCode');
  } catch (e) {
    print('ChallengeCubit - Disconnect error: $e');
    emit(ChallengeError(e.toString()));
  }
}

Future<Map<String, dynamic>?> joinChallenge({
  required String token,
  required String challengeCode,
}) async {
  try {
    // POST /live/challenges/join
    final response = await _repository.joinChallenge(
      token: token,
      challengeCode: challengeCode,
    );
    
    print('ChallengeCubit - Joined/rejoined challenge: $challengeCode');
    return response;
  } catch (e) {
    print('ChallengeCubit - Join error: $e');
    emit(ChallengeError(e.toString()));
    return null;
  }
}
```

---

## Testing Checklist

After implementing these fixes:

- [ ] Test app pause → disconnect called
- [ ] Test app resume → rejoin called with score preserved
- [ ] Test timer expiry triggers immediate check-advance
- [ ] Test endTime from server overrides client calculation
- [ ] Test inactive participants excluded from count
- [ ] Test reconnection after network loss
- [ ] Test multiple clients advancing simultaneously
- [ ] Test late answer rejection handling

---

## Files to Modify

1. `lib/features/challenges/presentation/view/screens/live_question_screen.dart`
2. `lib/features/challenges/presentation/bloc/challenge_cubit.dart` (if methods missing)
3. `lib/features/challenges/data/repositories/challenge_repository.dart` (if methods missing)
4. `lib/features/challenges/data/datasources/challenge_remote_data_source.dart` (if methods missing)

---

## Verification Commands

```bash
# Run tests
flutter test test/utils/time_normalization_test.dart

# Build and check for errors
flutter analyze

# Hot reload during development
flutter run --hot
```

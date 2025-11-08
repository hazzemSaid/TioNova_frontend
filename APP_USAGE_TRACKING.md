# App Usage Tracking Implementation

## Overview
Real-time app usage tracking has been successfully implemented in TioNova using Flutter's lifecycle management and Hive for persistent storage.

## Features

### ✅ Implemented Features

1. **Real-Time Usage Tracking**
   - Automatically tracks when the app is in foreground
   - Updates every second
   - Pauses when app goes to background
   - Resumes when app comes back to foreground

2. **Statistics Available**
   - Today's usage (minutes/hours)
   - Current streak (consecutive days)
   - Last 7 days usage
   - Weekly total usage
   - Monthly total usage
   - Session count per day

3. **Data Persistence**
   - All data stored in Hive (local database)
   - Survives app restarts
   - Organized by date (YYYY-MM-DD)

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── app_usage_tracker_service.dart  # Main tracking service
│   ├── widgets/
│   │   └── usage_stats_widget.dart         # Reusable UI widget
│   └── get_it/
│       └── services_locator.dart           # Service registration
└── main.dart                                # Service initialization
```

## Usage

### 1. Access the Service

```dart
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';

final usageTracker = getIt<AppUsageTrackerService>();
```

### 2. Get Usage Statistics

```dart
// Get today's usage in minutes
int minutes = usageTracker.getTodayUsageMinutes();

// Get formatted usage (e.g., "1h 30m" or "45m")
String formatted = usageTracker.getTodayUsageFormatted();

// Get current streak
int streak = usageTracker.getCurrentStreak();

// Get last 7 days data
List<Map<String, dynamic>> last7Days = usageTracker.getLast7DaysUsage();

// Get week total
int weekMinutes = usageTracker.getWeekUsageMinutes();

// Get month total
int monthMinutes = usageTracker.getMonthUsageMinutes();
```

### 3. Real-Time Updates

Use StreamBuilder for live updates:

```dart
StreamBuilder<int>(
  stream: usageTracker.getTodayUsageStream(),
  initialData: usageTracker.getTodayUsageMinutes(),
  builder: (context, snapshot) {
    final minutes = snapshot.data ?? 0;
    return Text('$minutes minutes');
  },
)
```

### 4. Display Usage Stats Widget

Simple display:
```dart
import 'package:tionova/core/widgets/usage_stats_widget.dart';

UsageStatsWidget() // Shows compact view
```

Detailed display with chart:
```dart
UsageStatsWidget(showDetailed: true) // Shows full stats with chart
```

## Implementation Details

### AppUsageTrackerService

**Methods:**
- `initialize()` - Start tracking (called automatically in main.dart)
- `dispose()` - Stop tracking and save data
- `getTodayUsageMinutes()` - Get today's usage
- `getTodayUsageFormatted()` - Get formatted string
- `getCurrentStreak()` - Get consecutive days streak
- `getLast7DaysUsage()` - Get array of last 7 days data
- `getWeekUsageMinutes()` - Get this week's total
- `getMonthUsageMinutes()` - Get this month's total
- `getTodayUsageStream()` - Stream for real-time updates
- `clearAllData()` - Reset all tracking data (for testing)

### Data Structure

Stored in Hive box named `app_usage`:

```dart
{
  "2025-11-07": {
    "totalSeconds": 2700,      // 45 minutes
    "sessions": 3,              // Number of app launches
    "lastSession": "2025-11-07T14:30:00.000Z",
    "lastUpdated": "2025-11-07T14:30:00.000Z"
  }
}
```

## Integration in Home Screen

The home screen now displays:
1. **Day Streak** - Real-time streak count
2. **Study Time** - Real-time today's usage (updates every second)

```dart
// In home_screen.dart
class _HomeScreenState extends State<HomeScreen> {
  final _usageTracker = getIt<AppUsageTrackerService>();

  // Statistics with real data
  final stats = [
    {
      'value': '${_usageTracker.getCurrentStreak()}',
      'label': 'Day Streak',
      'icon': Icons.local_fire_department
    },
    // ... other stats
  ];

  // Today's progress with real-time updates
  StreamBuilder<int>(
    stream: _usageTracker.getTodayUsageStream(),
    initialData: _usageTracker.getTodayUsageMinutes(),
    builder: (context, snapshot) {
      final realTimeUsage = snapshot.data ?? 0;
      return _TodayProgressCard(
        progress: {'studyTime': realTimeUsage, ...},
        // ...
      );
    },
  )
}
```

## Lifecycle Tracking

The service uses `WidgetsBindingObserver` to monitor app lifecycle:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      _onAppResumed();  // Start counting
      break;
    case AppLifecycleState.paused:
    case AppLifecycleState.inactive:
      _onAppPaused();   // Stop counting and save
      break;
  }
}
```

## Testing

To test the tracking:

```dart
// Clear all data
await usageTracker.clearAllData();

// Check today's usage
print('Today: ${usageTracker.getTodayUsageFormatted()}');

// Check streak
print('Streak: ${usageTracker.getCurrentStreak()} days');

// Get detailed data
final last7Days = usageTracker.getLast7DaysUsage();
for (var day in last7Days) {
  print('${day['date']}: ${day['totalSeconds']} seconds');
}
```

## Performance

- **Minimal Impact**: Updates once per second only when app is active
- **Efficient Storage**: Uses Hive for fast read/write operations
- **Smart Tracking**: Automatically pauses when app goes to background
- **Memory Safe**: Cleans up resources on dispose

## Future Enhancements

Potential improvements:
1. Add daily/weekly/monthly goals
2. Push notifications for study reminders
3. Usage analytics and insights
4. Compare usage with other users (leaderboard)
5. Export usage data as CSV/PDF
6. Set custom tracking categories (study, quiz, reading)
7. Integration with chapter/quiz completion metrics

## Troubleshooting

**Issue**: Usage not tracking
- **Solution**: Ensure `initialize()` is called in main.dart
- **Check**: Verify Hive box 'app_usage' is created

**Issue**: Streak not updating
- **Solution**: Make sure you use the app daily
- **Check**: Verify data is being saved (check Hive box)

**Issue**: Time seems incorrect
- **Solution**: Clear data with `clearAllData()`
- **Check**: Ensure device time is correct

## Notes

- Data is stored locally on device (not synced to cloud)
- Tracking starts automatically when app launches
- No user action required to enable tracking
- Privacy-friendly (no external servers involved)
- Works offline (no internet required)

## Example Output

```
Today's Usage: 45m
Current Streak: 7 days
This Week: 5.2h
Last 7 Days:
  2025-11-01: 30 minutes (2 sessions)
  2025-11-02: 45 minutes (3 sessions)
  2025-11-03: 60 minutes (4 sessions)
  2025-11-04: 35 minutes (2 sessions)
  2025-11-05: 50 minutes (3 sessions)
  2025-11-06: 40 minutes (2 sessions)
  2025-11-07: 45 minutes (3 sessions) ← Today
```

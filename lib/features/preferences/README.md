# Preferences Screen Documentation

## Overview
The Preferences Screen is a multi-step onboarding flow designed for first-time users to set up their study preferences. It collects user preferences across 6 steps and prepares the data to be sent to the server.

## Features

### Step 1: Daily Chapter Goal
- Slider to select how many chapters to study per day (1-10)
- Real-time value display
- Helper text showing recommended pace

### Step 2: Preferred Study Times
- Selection of preferred study time slot:
  - Early Morning (5-8 AM)
  - Morning (8-12 PM)
  - Afternoon (12-5 PM)
  - Evening (5-9 PM)
  - Night (9 PM+)

### Step 3: Daily Time Commitment
- Slider for daily study time (15-180 minutes)
- Quick selection buttons for common durations (15m, 30m, 60m)

### Step 4: Study Schedule
- Days per week selection (1-7 days)
- Quick selection buttons (3, 5, 7 days)
- Shows estimated chapters per week

### Step 5: Learning Goals
- Multi-select grid of learning goals:
  - Prepare for Exams
  - Learn New Topics
  - Review Materials
  - Improve Grades
  - Daily Practice
  - Career Development

### Step 6: Content Difficulty
- Selection of preferred content difficulty level:
  - **Easy**: Gentle pace, more explanations
  - **Medium**: Balanced difficulty and depth (default)
  - **Hard**: Challenging content, faster pace
  - **Progressive**: Start easy, gradually increase difficulty
- **Study Plan Summary**: Shows overview of all selections:
  - Chapters per day
  - Time per day
  - Days per week
  - Number of goals selected

## Navigation

### Using GoRouter

```dart
// Navigate to preferences screen
context.go('/preferences');

// Or using named route
context.goNamed('preferences');
```

### Integration with First-Time Login

To automatically show this screen after first-time sign-in, you can modify the authentication flow:

```dart
// In your auth cubit or login screen, after successful login:
if (user.isFirstTimeUser) {
  context.go('/preferences');
} else {
  context.go('/');
}
```

### Manual Navigation

You can also navigate from any screen:

```dart
ElevatedButton(
  onPressed: () {
    context.push('/preferences');
  },
  child: Text('Set Preferences'),
)
```

## Data Structure

The preferences screen collects data in the following format:

```json
{
  "studyPerDay": 2,
  "preferredStudyTimes": "evening",
  "dailyTimeCommitmentMinutes": 30,
  "daysPerWeek": 5,
  "goals": ["Prepare for Exams", "Review Materials"],
  "reminderEnabled": true,
  "reminderTimes": ["09:00", "19:00"],
  "contentDifficulty": "medium"
}
```

## Customization

### To modify the goals list:
Edit the `_availableGoals` list in `preferences_screen.dart`:

```dart
final List<Map<String, dynamic>> _availableGoals = [
  {'icon': '🎯', 'label': 'Your Goal', 'value': 'Your Goal'},
  // Add more goals here
];
```

### To change default values:
Update the initial state variables:

```dart
double _studyPerDay = 2; // Default chapters per day
String? _preferredStudyTime; // Default to null (user must select)
double _dailyTimeCommitmentMinutes = 30; // Default minutes
double _daysPerWeek = 5; // Default days
```

### To integrate with your backend:
Modify the `_submitPreferences()` method:

```dart
void _submitPreferences() async {
  final preferencesData = {
    'studyPerDay': _studyPerDay.toInt(),
    'preferredStudyTimes': _preferredStudyTime?.toLowerCase() ?? 'evening',
    'dailyTimeCommitmentMinutes': _dailyTimeCommitmentMinutes.toInt(),
    'daysPerWeek': _daysPerWeek.toInt(),
    'goals': _selectedGoals.toList(),
    'reminderEnabled': true,
    'reminderTimes': ['09:00', '19:00'],
    'contentDifficulty': 'medium',
  };

  // Send to your API
  await yourPreferencesRepository.updatePreferences(preferencesData);
  
  // Navigate to home
  context.go('/');
}
```

## User Experience

- **Progress Bar**: Shows current step and percentage completion
- **Validation**: Continue button is disabled until required fields are filled
- **Back Button**: Available from step 2 onwards
- **Skip Option**: Users can skip the entire flow with "Skip for now"
- **Responsive**: Adapts to different screen sizes
- **Theme Support**: Works with both light and dark themes

## Testing

To test the preferences screen:

1. Run the app
2. Navigate to `/preferences` using the browser or programmatically
3. Go through all 5 steps
4. Check console output for the submitted data structure

## Future Enhancements

Possible improvements:
- Add animation between steps
- Save progress locally (resume if user exits)
- Add more validation rules
- Integrate with a preferences Cubit/Bloc for state management
- Add API integration for submitting preferences
- Add confirmation dialog before skipping

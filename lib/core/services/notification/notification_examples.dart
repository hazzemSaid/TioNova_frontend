// Example: How to use Firebase Push Notifications in TioNova
// Place this file in lib/core/services/notification/ for reference

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tionova/core/services/notification/notification_service.dart';

/// Example 1: Basic initialization and getting FCM token
Future<void> exampleBasicSetup() async {
  final notificationService = NotificationService();

  // Initialize is already called in main.dart, but here's what happens:
  // 1. Request notification permissions
  // 2. Setup Android notification channel
  // 3. Configure foreground message handling
  // 4. Register background message handler

  // Get FCM token (used to send notifications to specific device)
  final token = await notificationService.getFcmToken();
  print('Device FCM Token: $token');

  // Store this token in your Firebase database under the user's profile
  // This allows you to send notifications to specific users later
}

/// Example 2: Subscribe to topics for mass notifications
Future<void> exampleTopicSubscription() async {
  final notificationService = NotificationService();

  // Subscribe to topics based on user context
  // These subscriptions persist across app restarts

  // Subscribe to global topic (all users receive this)
  await notificationService.subscribeToTopic('all_users');

  // Subscribe to class-specific topic
  await notificationService.subscribeToTopic('class_101');

  // Subscribe to feature-specific topics
  await notificationService.subscribeToTopics([
    'challenges', // User interested in challenges
    'quizzes', // User interested in quizzes
    'announcements', // User wants announcements
  ]);

  // Unsubscribe when user logs out
  // await notificationService.unsubscribeFromTopics([...]);
}

/// Example 3: Handle notification tap with custom routing
Future<void> exampleNotificationTap(RemoteMessage message) async {
  print('Notification tapped: ${message.notification?.title}');

  // Extract custom data from notification
  final data = message.data;
  final type = data['type'];
  final id = data['id'];

  // Navigate based on notification type
  switch (type) {
    case 'challenge':
      // Navigate to challenge screen
      // context.go('/challenges/$id');
      print('Navigate to challenge: $id');
      break;

    case 'quiz':
      // Navigate to quiz screen
      // context.go('/quizzes/$id');
      print('Navigate to quiz: $id');
      break;

    case 'announcement':
      // Navigate to announcements
      // context.go('/announcements');
      print('Navigate to announcements');
      break;

    default:
      print('Unknown notification type: $type');
  }
}

/// Example 4: Handling initial message (app opened from notification)
Future<void> exampleInitialMessage() async {
  final notificationService = NotificationService();

  // Call this in your app initialization to handle:
  // - App launched from terminated state by tapping a notification
  // - App in background but not terminated

  final initialMessage = await notificationService.getInitialMessage();

  if (initialMessage != null) {
    // App was opened from notification
    print('Initial message: ${initialMessage.notification?.title}');

    // Extract and handle the notification data
    final data = initialMessage.data;
    // Navigate based on data...
  }
}

/// Example 5: Sending notifications from Cloud Function
/// Deploy this to Firebase Cloud Functions
/*
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Send challenge notification when new challenge is created
export const onNewChallenge = functions.database
  .ref('/challenges/{challengeId}')
  .onCreate(async (snapshot) => {
    const challenge = snapshot.val();
    
    const message = {
      notification: {
        title: `New Challenge: ${challenge.name}`,
        body: 'A new challenge has started! Tap to join.',
      },
      data: {
        type: 'challenge',
        id: snapshot.key!,
        difficulty: challenge.difficulty,
      },
      topic: 'all_users', // Send to all users subscribed to 'all_users' topic
    };
    
    try {
      await admin.messaging().send(message);
      console.log('Challenge notification sent');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

// Send class announcement
export const sendClassAnnouncement = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required'
    );
  }
  
  const { title, body, classId } = data;
  
  const message = {
    notification: { title, body },
    data: {
      type: 'announcement',
      classId: classId,
    },
    topic: `class_${classId}`, // Send to specific class
  };
  
  await admin.messaging().send(message);
  return { success: true };
});

// Send notification to specific user
export const sendUserNotification = functions.https.onCall(async (data, context) => {
  const { token, title, body, type, id } = data;
  
  const message = {
    notification: { title, body },
    data: { type, id },
    token: token, // Send to specific device token
  };
  
  await admin.messaging().send(message);
  return { success: true };
});
*/

/// Example 6: Delete token on logout
Future<void> exampleLogout() async {
  final notificationService = NotificationService();

  // When user logs out, clean up notification subscription
  await notificationService.deleteToken();

  // Also unsubscribe from topics
  await notificationService.unsubscribeFromTopics([
    'all_users',
    'challenges',
    'quizzes',
    'announcements',
  ]);

  print('Notifications cleaned up on logout');
}

/// Example 7: Check notification permission status
Future<void> exampleCheckPermission() async {
  final notificationService = NotificationService();

  final hasPermission = await notificationService.hasNotificationPermission();

  if (!hasPermission) {
    print('User has not granted notification permission');
    // Show a dialog encouraging user to enable notifications
  }
}

/// Example 8: Using in a Cubit/BLoC for real-time challenges
/*
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChallengesBloc extends Cubit<ChallengesState> {
  final NotificationService _notificationService = NotificationService();
  
  ChallengesBloc() : super(ChallengesInitial()) {
    _setupNotificationHandling();
  }
  
  void _setupNotificationHandling() {
    // Handle challenge notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'challenge') {
        // Refresh challenges list when notification received
        refreshChallenges();
        
        // Show toast or snackbar
        // ScaffoldMessenger.of(context).showSnackBar(...)
      }
    });
  }
  
  Future<void> refreshChallenges() async {
    // Fetch latest challenges from Firebase
  }
  
  @override
  Future<void> close() {
    // Cleanup
    return super.close();
  }
}
*/

/// Example 9: Notification payload structure
/*
// Standard notification payload for TioNova
{
  "notification": {
    "title": "String (max 65 characters)",
    "body": "String (max 240 characters)",
    "image": "URL to image" // Optional
  },
  "data": {
    "type": "challenge|quiz|announcement|quiz_result",
    "id": "Unique ID of resource",
    "classId": "Class ID if applicable",
    "userId": "User ID if personal",
    "deeplink": "Full deep link URL" // Optional
  },
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channel_id": "high_importance_channel"
    }
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    },
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
*/

/// Example 10: Handling notification preferences by user
Future<void> exampleUserPreferences(String userId) async {
  final notificationService = NotificationService();

  // Based on user preferences, subscribe to topics
  // This would typically come from user settings in your database

  const userPreferences = {
    'challenges': true,
    'quizzes': true,
    'announcements': false,
    'messages': true,
  };

  final topicsToSubscribe = <String>[];

  if (userPreferences['challenges'] ?? true) {
    topicsToSubscribe.add('challenges');
  }
  if (userPreferences['quizzes'] ?? true) {
    topicsToSubscribe.add('quizzes');
  }
  if (userPreferences['announcements'] ?? false) {
    topicsToSubscribe.add('announcements');
  }
  if (userPreferences['messages'] ?? true) {
    topicsToSubscribe.add('messages');
  }

  // Subscribe to all enabled topics
  await notificationService.subscribeToTopics(topicsToSubscribe);
}

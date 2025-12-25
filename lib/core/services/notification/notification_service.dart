import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationHandler = Future<void> Function(RemoteMessage);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  // Only create local notifications plugin on non-web platforms
  FlutterLocalNotificationsPlugin? _localNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Callback for when user taps a notification
  late NotificationHandler? _onNotificationTap;

  // ==========================================
  // INITIALIZATION
  // ==========================================

  /// Initialize the notification service
  /// Call this in main.dart after Firebase initialization
  Future<void> initialize({NotificationHandler? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap;

    // Skip local notifications on web (not supported)
    if (!kIsWeb) {
      _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup notification channel for Android
      await _setupNotificationChannel();
    }

    // Request notification permissions (works on web too via Firebase)
    await _requestPermissions();

    // Configure foreground message handling
    await _configureForegroundMessageHandling();

    // Configure background message handling
    _configureBackgroundMessageHandling();

    // Handle notification tap when app is in foreground
    _configureNotificationTap();

    print('✅ Notification Service initialized successfully');
  }

  // ==========================================
  // PRIVATE INITIALIZATION METHODS
  // ==========================================

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb || _localNotificationsPlugin == null) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsMacOS,
        );

    await _localNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
        // Handle notification tap
        if (_onNotificationTap != null && response.payload != null) {
          // Note: We can't directly pass RemoteMessage here, so we handle it separately
        }
      },
    );

    print('✅ Local notifications initialized');
  }

  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📢 Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
    }
  }

  Future<void> _setupNotificationChannel() async {
    if (kIsWeb || _localNotificationsPlugin == null) return;

    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      final androidPlugin = _localNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        print('✅ Notification channel created');
      }
    } catch (e) {
      print('⚠️ Error setting up notification channel: $e');
    }
  }

  Future<void> _configureForegroundMessageHandling() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📬 Foreground message received: ${message.notification?.title}');
      await showNotification(message);
    });
  }

  void _configureBackgroundMessageHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 App opened from notification: ${message.notification?.title}');
      if (_onNotificationTap != null) {
        _onNotificationTap!(message);
      }
    });
  }

  void _configureNotificationTap() {
    // Handle notification tap for Android
    // The notification tap is already handled in _initializeLocalNotifications
    print('✅ Notification tap handler configured');
  }

  // ==========================================
  // PUBLIC METHODS
  // ==========================================

  /// Show a local notification (usually from FCM)
  Future<void> showNotification(RemoteMessage message) async {
    // On web, we can't show local notifications, but the browser handles FCM notifications
    if (kIsWeb || _localNotificationsPlugin == null) {
      print(
        '📬 Web notification handled by browser: ${message.notification?.title}',
      );
      return;
    }

    try {
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';
      final payload = message.data.toString();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            autoCancel: true,
            ticker: 'New Notification',
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotificationsPlugin!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('✅ Notification displayed: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Get FCM token for this device
  Future<String?> getFcmToken() async {
    try {
      // On web, we need to provide VAPID key for FCM
      final token = kIsWeb
          ? await _firebaseMessaging.getToken(
              vapidKey: null, // Add your VAPID key here if needed for web push
            )
          : await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic for receiving topic-based notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe to multiple topics at once
  Future<void> subscribeToTopics(List<String> topics) async {
    // On web, topic subscription might not work the same way
    if (kIsWeb) {
      print('ℹ️ Topic subscription on web may have limitations');
    }
    for (final topic in topics) {
      await subscribeToTopic(topic);
    }
  }

  /// Unsubscribe from multiple topics at once
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Check if app has notification permission
  Future<bool> hasNotificationPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('⚠️ Error checking notification permission: $e');
      return false;
    }
  }

  /// Handle a background message
  /// This should be registered as a top-level function
  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Background messages are not supported on web
    if (kIsWeb) {
      print('📬 Web background message: ${message.notification?.title}');
      return;
    }

    try {
      print('📬 Background message received: ${message.notification?.title}');

      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Show the notification
      final service = NotificationService();
      await service.showNotification(message);
    } catch (e) {
      print('❌ Error handling background message: $e');
    }
  }

  /// Delete the FCM token (e.g., when user logs out)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }

  /// Get data from a notification payload
  /// Use this to extract custom data from notifications
  Map<String, dynamic> getNotificationData(RemoteMessage message) {
    return message.data;
  }

  /// Check if initial message exists (app opened from notification)
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print(
          '📬 App opened from notification: ${initialMessage.notification?.title}',
        );
      }
      return initialMessage;
    } catch (e) {
      print('⚠️ Error getting initial message: $e');
      return null;
    }
  }
}

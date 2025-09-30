// // import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:tionova/core/services/notification/notification_service.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   final _service = NotificationService();
//   String? _token;
//   RemoteMessage? _lastMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       setState(() {
//         _lastMessage = message;
//       });
//       await _service.showNotification(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       setState(() {
//         _lastMessage = message;
//       });
//     });
//   }

//   Future<void> _loadToken() async {
//     final t = await _service.getFcmToken();
//     setState(() => _token = t);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Device Token:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             SelectableText(_token ?? 'Fetching token...'),
//             const Divider(height: 32),
//             const Text(
//               'Last Message:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(_lastMessage?.notification?.title ?? 'No messages yet'),
//             Text(_lastMessage?.notification?.body ?? ''),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:tionova/core/utils/platform_utils.dart';

// /// Service to check for app updates and download new APK
// /// This is for direct APK distribution (not Play Store)
// class AppUpdateService {
//   static final AppUpdateService _instance = AppUpdateService._internal();
//   factory AppUpdateService() => _instance;
//   AppUpdateService._internal();

//   final Dio _dio = Dio();

//   // Replace with your actual update check API endpoint
//   static const String _updateCheckUrl = 'https://your-api.com/api/check-update';

//   bool _isChecking = false;
//   bool _isDownloading = false;
//   double _downloadProgress = 0.0;
//   String? _downloadedFilePath;

//   /// Check if update is available
//   Future<UpdateInfo?> checkForUpdate() async {
//     // Skip on Web
//     if (isWeb) return null;

//     if (_isChecking) return null;

//     try {
//       _isChecking = true;
//       print('🔍 AppUpdateService: Checking for updates...');

//       // Get current app version
//       final packageInfo = await PackageInfo.fromPlatform();
//       final currentVersion = packageInfo.version;
//       final currentBuildNumber = packageInfo.buildNumber;

//       print('ℹ️ Current version: $currentVersion ($currentBuildNumber)');

//       // Check with your backend API
//       final response = await _dio.get(
//         _updateCheckUrl,
//         queryParameters: {
//           'current_version': currentVersion,
//           'current_build': currentBuildNumber,
//           'platform': Platform.isAndroid ? 'android' : 'ios',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;

//         // Parse response
//         if (data['update_available'] == true) {
//           print('✅ Update available: ${data['latest_version']}');
//           return UpdateInfo(
//             latestVersion: data['latest_version'],
//             latestBuildNumber: data['latest_build_number'].toString(),
//             downloadUrl: data['download_url'],
//             releaseNotes: data['release_notes'] ?? '',
//             fileSize: data['file_size_mb'] ?? 0.0,
//             isMandatory: data['is_mandatory'] ?? false,
//             minRequiredVersion: data['min_required_version'],
//           );
//         } else {
//           print('ℹ️ No updates available');
//           return null;
//         }
//       }

//       return null;
//     } catch (e) {
//       print('❌ Error checking for update: $e');
//       return null;
//     } finally {
//       _isChecking = false;
//     }
//   }

//   /// Download APK update
//   Future<String?> downloadUpdate({
//     required String downloadUrl,
//     required Function(double) onProgress,
//   }) async {
//     // Skip on Web
//     if (isWeb) return null;

//     if (_isDownloading) {
//       print('⚠️ Already downloading');
//       return null;
//     }

//     try {
//       _isDownloading = true;
//       _downloadProgress = 0.0;

//       print('📥 Starting download from: $downloadUrl');

//       // Request storage permission
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           print('❌ Storage permission denied');
//           return null;
//         }
//       }

//       // Get download directory
//       final directory = await getExternalStorageDirectory();
//       if (directory == null) {
//         print('❌ Could not access storage directory');
//         return null;
//       }

//       final savePath = '${directory.path}/tionova_update.apk';
//       print('💾 Save path: $savePath');

//       // Download the APK
//       await _dio.download(
//         downloadUrl,
//         savePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             _downloadProgress = (received / total);
//             onProgress(_downloadProgress);
//             print(
//               '📊 Download progress: ${(_downloadProgress * 100).toStringAsFixed(1)}%',
//             );
//           }
//         },
//       );

//       print('✅ Download complete: $savePath');
//       _downloadedFilePath = savePath;
//       return savePath;
//     } catch (e) {
//       print('❌ Download error: $e');
//       return null;
//     } finally {
//       _isDownloading = false;
//     }
//   }

//   /// Install downloaded APK
//   Future<bool> installUpdate(String apkPath) async {
//     // Skip on Web
//     if (isWeb) return false;

//     try {
//       print('📦 Installing APK: $apkPath');

//       // Check if file exists
//       final file = File(apkPath);
//       if (!await file.exists()) {
//         print('❌ APK file not found');
//         return false;
//       }

//       // Request install permission for Android 8+
//       if (Platform.isAndroid) {
//         final status = await Permission.requestInstallPackages.request();
//         if (!status.isGranted) {
//           print('❌ Install permission denied');
//           return false;
//         }
//       }

//       // Open APK for installation
//       final result = await OpenFile.open(apkPath);
//       print('📲 Install result: ${result.message}');

//       return result.type == ResultType.done;
//     } catch (e) {
//       print('❌ Install error: $e');
//       return false;
//     }
//   }

//   /// Show update dialog
//   static void showUpdateDialog({
//     required BuildContext context,
//     required UpdateInfo updateInfo,
//     required VoidCallback onUpdate,
//     required VoidCallback onLater,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: !updateInfo.isMandatory,
//       builder: (context) {
//         final colorScheme = Theme.of(context).colorScheme;

//         return WillPopScope(
//           onWillPop: () async => !updateInfo.isMandatory,
//           child: AlertDialog(
//             backgroundColor: colorScheme.surface,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: Row(
//               children: [
//                 Icon(
//                   updateInfo.isMandatory
//                       ? Icons.system_update_alt
//                       : Icons.system_update,
//                   color: updateInfo.isMandatory
//                       ? Colors.orange
//                       : colorScheme.primary,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         updateInfo.isMandatory
//                             ? 'Required Update'
//                             : 'Update Available',
//                         style: TextStyle(
//                           color: colorScheme.onSurface,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         'Version ${updateInfo.latestVersion}',
//                         style: TextStyle(
//                           color: colorScheme.onSurfaceVariant,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (updateInfo.releaseNotes.isNotEmpty) ...[
//                     Text(
//                       'What\'s New:',
//                       style: TextStyle(
//                         color: colorScheme.onSurface,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         updateInfo.releaseNotes,
//                         style: TextStyle(
//                           color: colorScheme.onSurfaceVariant,
//                           fontSize: 13,
//                           height: 1.5,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.download,
//                         color: colorScheme.onSurfaceVariant,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Size: ${updateInfo.fileSize.toStringAsFixed(1)} MB',
//                         style: TextStyle(
//                           color: colorScheme.onSurfaceVariant,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (updateInfo.isMandatory) ...[
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: Colors.orange.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.warning_amber,
//                             color: Colors.orange,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'This update is required to continue using the app.',
//                               style: TextStyle(
//                                 color: colorScheme.onSurface,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               if (!updateInfo.isMandatory)
//                 TextButton(
//                   onPressed: onLater,
//                   style: TextButton.styleFrom(
//                     foregroundColor: colorScheme.onSurfaceVariant,
//                   ),
//                   child: const Text('Later'),
//                 ),
//               ElevatedButton(
//                 onPressed: onUpdate,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: updateInfo.isMandatory
//                       ? Colors.orange
//                       : colorScheme.primary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Update Now'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// Show downloading dialog with progress
//   static void showDownloadingDialog({
//     required BuildContext context,
//     required Stream<double> progressStream,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         final colorScheme = Theme.of(context).colorScheme;

//         return WillPopScope(
//           onWillPop: () async => false,
//           child: AlertDialog(
//             backgroundColor: colorScheme.surface,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             content: StreamBuilder<double>(
//               stream: progressStream,
//               builder: (context, snapshot) {
//                 final progress = snapshot.data ?? 0.0;
//                 final percentage = (progress * 100).toStringAsFixed(0);

//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(height: 16),
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 80,
//                           height: 80,
//                           child: CircularProgressIndicator(
//                             value: progress,
//                             strokeWidth: 6,
//                             backgroundColor:
//                                 colorScheme.surfaceContainerHighest,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '$percentage%',
//                           style: TextStyle(
//                             color: colorScheme.onSurface,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Downloading Update...',
//                       style: TextStyle(
//                         color: colorScheme.onSurface,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Please wait',
//                       style: TextStyle(
//                         color: colorScheme.onSurfaceVariant,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// Model for update information
// class UpdateInfo {
//   final String latestVersion;
//   final String latestBuildNumber;
//   final String downloadUrl;
//   final String releaseNotes;
//   final double fileSize;
//   final bool isMandatory;
//   final String? minRequiredVersion;

//   UpdateInfo({
//     required this.latestVersion,
//     required this.latestBuildNumber,
//     required this.downloadUrl,
//     required this.releaseNotes,
//     required this.fileSize,
//     required this.isMandatory,
//     this.minRequiredVersion,
//   });
// }

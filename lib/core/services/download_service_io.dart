// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// /// Get download path - IO implementation
// Future<String?> getDownloadPath() async {
//   try {
//     if (Platform.isAndroid) {
//       // Try to get the Downloads directory

//       // First try to get external storage directory
//       final externalDir = await getExternalStorageDirectory();
//       if (externalDir != null) {
//         // Navigate to Downloads folder
//         final downloadPath = Directory('/storage/emulated/0/Download');
//         if (await downloadPath.exists()) {
//           return downloadPath.path;
//         }

//         // Fallback to creating Downloads in external storage
//         final fallbackPath = Directory('${externalDir.path}/Downloads');
//         if (!await fallbackPath.exists()) {
//           await fallbackPath.create(recursive: true);
//         }
//         return fallbackPath.path;
//       }

//       // Last resort: use app documents directory
//       final appDocDir = await getApplicationDocumentsDirectory();
//       final downloadDir = Directory('${appDocDir.path}/Downloads');
//       if (!await downloadDir.exists()) {
//         await downloadDir.create(recursive: true);
//       }
//       return downloadDir.path;
//     } else if (Platform.isIOS) {
//       final appDocDir = await getApplicationDocumentsDirectory();
//       return appDocDir.path;
//     }
//   } catch (e) {
//     print('Error getting download path: $e');
//   }
//   return null;
// }

// /// Download PDF to device - IO implementation
// Future<bool> downloadPDF({
//   required Uint8List pdfBytes,
//   required String fileName,
//   required BuildContext context,
// }) async {
//   try {
//     // Get download path
//     final downloadPath = await getDownloadPath();
//     if (downloadPath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to access download directory'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }

//     // Ensure fileName has .pdf extension
//     String finalFileName = fileName;
//     if (!fileName.toLowerCase().endsWith('.pdf')) {
//       finalFileName = '$fileName.pdf';
//     }

//     // Create unique filename if file already exists
//     String fullPath = '$downloadPath/$finalFileName';
//     int counter = 1;
//     while (await File(fullPath).exists()) {
//       final nameWithoutExt = finalFileName.replaceAll('.pdf', '');
//       finalFileName = '${nameWithoutExt}_$counter.pdf';
//       fullPath = '$downloadPath/$finalFileName';
//       counter++;
//     }

//     // Write file
//     final file = File(fullPath);
//     await file.writeAsBytes(pdfBytes);

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('PDF downloaded: $finalFileName'),
//         backgroundColor: Colors.green,
//       ),
//     );

//     return true;
//   } catch (e) {
//     print('Error downloading PDF: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Download failed: $e'),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return false;
//   }
// }

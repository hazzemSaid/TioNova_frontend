// import 'package:flutter/material.dart';
// import 'package:tionova/core/services/download_service.dart';

// class CacheManagementDialog extends StatelessWidget {
//   const CacheManagementDialog({super.key});

//   static void show(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const CacheManagementDialog(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cacheInfo = DownloadService.getCacheInfo();
//     final items = cacheInfo['items'] as List<Map<String, dynamic>>;

//     return AlertDialog(
//       title: const Text('PDF Cache Management'),
//       content: Container(
//         width: double.maxFinite,
//         constraints: const BoxConstraints(maxHeight: 400),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Cache summary
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Cache Summary',
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text('Total Files: ${cacheInfo['count']}'),
//                   Text('Total Size: ${cacheInfo['sizeFormatted']}'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             if (items.isEmpty)
//               const Center(
//                 child: Text(
//                   'No cached PDFs found',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               )
//             else ...[
//               Text(
//                 'Cached PDFs',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         leading: const Icon(
//                           Icons.picture_as_pdf,
//                           color: Colors.red,
//                         ),
//                         title: Text(
//                           item['chapterTitle'] ?? item['fileName'],
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Size: ${item['fileSize']}'),
//                             Text(
//                               'Cached: ${_formatDate(item['cachedAt'])}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () async {
//                             await DownloadService.clearCachedPDF(
//                               item['chapterId'],
//                             );
//                             Navigator.of(context).pop();
//                             // Show updated dialog
//                             show(context);
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         if (items.isNotEmpty)
//           TextButton(
//             onPressed: () async {
//               await DownloadService.clearAllCache();
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('All cached PDFs cleared'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: const Text('Clear All', style: TextStyle(color: Colors.red)),
//           ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Close'),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inDays > 0) {
//       return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }

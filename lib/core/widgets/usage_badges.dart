// import 'package:flutter/material.dart';
// import 'package:tionova/core/get_it/services_locator.dart';
// import 'package:tionova/core/services/app_usage_tracker_service.dart';

// /// Simple badge showing today's usage time
// /// Can be placed anywhere in the app
// class UsageTimeBadge extends StatelessWidget {
//   final bool showIcon;
//   final Color? backgroundColor;
//   final Color? textColor;

//   const UsageTimeBadge({
//     super.key,
//     this.showIcon = true,
//     this.backgroundColor,
//     this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final usageTracker = getIt<AppUsageTrackerService>();
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return StreamBuilder<int>(
//       stream: usageTracker.getTodayUsageStream(),
//       initialData: usageTracker.getTodayUsageMinutes(),
//       builder: (context, snapshot) {
//         final usageText = usageTracker.getTodayUsageFormatted();

//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             color: backgroundColor ?? colorScheme.primaryContainer,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (showIcon) ...[
//                 Icon(
//                   Icons.access_time_rounded,
//                   size: 14,
//                   color: textColor ?? colorScheme.onPrimaryContainer,
//                 ),
//                 const SizedBox(width: 4),
//               ],
//               Text(
//                 usageText,
//                 style: textTheme.bodySmall?.copyWith(
//                   color: textColor ?? colorScheme.onPrimaryContainer,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// /// Simple streak badge
// class StreakBadge extends StatelessWidget {
//   final bool showIcon;
//   final Color? backgroundColor;
//   final Color? textColor;

//   const StreakBadge({
//     super.key,
//     this.showIcon = true,
//     this.backgroundColor,
//     this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final usageTracker = getIt<AppUsageTrackerService>();
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     final streak = usageTracker.getCurrentStreak();

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: backgroundColor ?? colorScheme.errorContainer,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (showIcon) ...[
//             Icon(
//               Icons.local_fire_department_rounded,
//               size: 14,
//               color: textColor ?? colorScheme.onErrorContainer,
//             ),
//             const SizedBox(width: 4),
//           ],
//           Text(
//             '$streak ${streak == 1 ? 'day' : 'days'}',
//             style: textTheme.bodySmall?.copyWith(
//               color: textColor ?? colorScheme.onErrorContainer,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

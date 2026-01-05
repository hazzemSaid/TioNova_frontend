// import 'package:flutter/material.dart';
// import 'package:tionova/core/get_it/services_locator.dart';
// import 'package:tionova/core/services/app_usage_tracker_service.dart';

// /// Widget to display app usage statistics
// class UsageStatsWidget extends StatelessWidget {
//   final bool showDetailed;

//   const UsageStatsWidget({super.key, this.showDetailed = false});

//   @override
//   Widget build(BuildContext context) {
//     final usageTracker = getIt<AppUsageTrackerService>();
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;

//     return StreamBuilder<int>(
//       stream: usageTracker.getTodayUsageStream(),
//       initialData: usageTracker.getTodayUsageMinutes(),
//       builder: (context, snapshot) {
//         final todayFormatted = usageTracker.getTodayUsageFormatted();
//         final streak = usageTracker.getCurrentStreak();
//         final weekMinutes = usageTracker.getWeekUsageMinutes();

//         if (!showDetailed) {
//           // Simple display
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: colorScheme.primaryContainer.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.access_time, size: 16, color: colorScheme.primary),
//                 const SizedBox(width: 6),
//                 Text(
//                   todayFormatted,
//                   style: textTheme.bodySmall?.copyWith(
//                     color: colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Icon(
//                   Icons.local_fire_department,
//                   size: 16,
//                   color: colorScheme.error,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   '$streak days',
//                   style: textTheme.bodySmall?.copyWith(
//                     color: colorScheme.error,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Detailed display
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Usage Statistics',
//                   style: textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Today's usage
//                 _StatRow(
//                   icon: Icons.today,
//                   label: 'Today',
//                   value: todayFormatted,
//                   color: colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),

//                 // Streak
//                 _StatRow(
//                   icon: Icons.local_fire_department,
//                   label: 'Current Streak',
//                   value: '$streak days',
//                   color: colorScheme.error,
//                 ),
//                 const SizedBox(height: 16),

//                 // Week usage
//                 _StatRow(
//                   icon: Icons.calendar_view_week,
//                   label: 'This Week',
//                   value: '${(weekMinutes / 60).toStringAsFixed(1)}h',
//                   color: colorScheme.tertiary,
//                 ),
//                 const SizedBox(height: 20),

//                 // Last 7 days chart
//                 Text(
//                   'Last 7 Days',
//                   style: textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _Last7DaysChart(usageTracker: usageTracker),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _StatRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _StatRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 16),
//         Expanded(child: Text(label, style: textTheme.bodyLarge)),
//         Text(
//           value,
//           style: textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _Last7DaysChart extends StatelessWidget {
//   final AppUsageTrackerService usageTracker;

//   const _Last7DaysChart({required this.usageTracker});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final last7Days = usageTracker.getLast7DaysUsage();

//     // Find max value for scaling
//     final maxMinutes = last7Days.isEmpty
//         ? 60
//         : last7Days
//               .map((day) => (day['totalSeconds'] as int) / 60)
//               .reduce((a, b) => a > b ? a : b)
//               .toInt();
//     final scaledMax = maxMinutes < 60 ? 60 : (maxMinutes ~/ 60 + 1) * 60;

//     return SizedBox(
//       height: 120,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: last7Days.asMap().entries.map((entry) {
//           final day = entry.value;
//           final minutes = (day['totalSeconds'] as int) / 60;
//           final height = scaledMax > 0 ? (minutes / scaledMax) * 100 : 0;

//           // Get day name (first letter)
//           final dateStr = day['date'] as String;
//           final date = DateTime.parse(dateStr);
//           final dayName = _getDayName(date.weekday);

//           return Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (minutes > 0)
//                     Text(
//                       '${minutes.round()}m',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                   Container(
//                     height: height.clamp(4.0, 100.0).toDouble(),
//                     decoration: BoxDecoration(
//                       color: minutes > 0
//                           ? colorScheme.primary
//                           : colorScheme.surfaceVariant,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     dayName,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   String _getDayName(int weekday) {
//     switch (weekday) {
//       case DateTime.monday:
//         return 'M';
//       case DateTime.tuesday:
//         return 'T';
//       case DateTime.wednesday:
//         return 'W';
//       case DateTime.thursday:
//         return 'T';
//       case DateTime.friday:
//         return 'F';
//       case DateTime.saturday:
//         return 'S';
//       case DateTime.sunday:
//         return 'S';
//       default:
//         return '';
//     }
//   }
// }

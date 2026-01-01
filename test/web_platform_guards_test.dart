import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tionova/features/folder/presentation/view/widgets/add_note_bottom_sheet.dart';
import 'package:tionova/core/services/shorebird_service.dart';
import 'package:tionova/core/services/download_service.dart';

void main() {
  group('Web platform guards', () {
    testWidgets('AddNoteBottomSheet shows SnackBar on Start Recording (web)', (tester) async {
      final accent = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddNoteBottomSheet(
              chapterId: 'test_chapter',
              accentColor: accent,
              onNoteAdded: () {},
              initialNoteType: 'voice',
            ),
          ),
        ),
      );

      // Ensure UI is built
      await tester.pumpAndSettle();

      // Tap Start Recording
      final startButton = find.widgetWithText(ElevatedButton, 'Start Recording');
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pump();

      // Expect SnackBar appears with web limitation message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Voice recording is not supported on Web yet'),
        ),
        findsOneWidget,
      );
    });

    test('ShorebirdService.initialize returns early on web', () async {
      final service = ShorebirdService();
      // Should not throw and should return quickly on web
      await service.initialize();
      // No explicit assertions needed; lack of exception indicates guard works
    });

    test('DownloadService.getDownloadPath is null on web', () async {
      final path = await DownloadService.getDownloadPath();
      expect(path, isNull);
    });
  });
}

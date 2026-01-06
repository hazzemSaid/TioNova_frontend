import 'package:flutter_test/flutter_test.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';

void main() {
  group('Null Safety Model Tests', () {
    test('UserModel.fromJson should handle null/missing values', () {
      final json = <String, dynamic>{};
      final user = UserModel.fromJson(json);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.username, '');
      expect(user.profilePicture, '');
      expect(user.streak, 0);
      expect(user.verified, false);
    });

    test('UserModel.fromJson should handle incorrect types', () {
      final json = <String, dynamic>{
        'user_id': 123,
        'email': null,
        'streak': '5',
        'verified': 'true',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, '');
      expect(user.streak, 5);
      expect(user.verified, true);
    });

    test('ProfileModel.fromJson should handle null/missing values', () {
      final json = <String, dynamic>{};
      final profile = ProfileModel.fromJson(json);

      expect(profile.streak, 0);
      expect(profile.lastActiveDate, isNull);
      expect(profile.totalQuizzesTaken, 0);
      expect(profile.totalMindmapsCreated, 0);
      expect(profile.totalSummariesCreated, 0);
      expect(profile.averageQuizScore, 0.0);
    });

    test('SummaryResponse.fromJson should handle empty/null summary field', () {
      final json = <String, dynamic>{'success': true, 'summary': null};
      final response = SummaryResponse.fromJson(json);

      expect(response.success, true);
      expect(response.summaries, isEmpty);
    });

    test(
      'SummaryResponse.fromJson should handle invalid summary field type',
      () {
        final json = <String, dynamic>{'success': true, 'summary': 'invalid'};
        final response = SummaryResponse.fromJson(json);

        expect(response.success, true);
        expect(response.summaries, isEmpty);
      },
    );
  });
}

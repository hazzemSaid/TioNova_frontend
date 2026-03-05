// Test data fixtures for unit and widget tests
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';

// ========== AUTH TEST DATA ==========

/// Sample user for testing
final testUser = UserModel(
  id: 'test-user-id-123',
  email: 'test@example.com',
  username: 'testuser',
  profilePicture: 'https://example.com/avatar.png',
  streak: 5,
  verified: true,
);

/// Sample user without avatar
final testUserNoAvatar = UserModel(
  id: 'test-user-id-456',
  email: 'test2@example.com',
  username: 'testuser2',
  profilePicture: '',
  streak: 0,
  verified: false,
);

/// Sample login credentials
const testEmail = 'test@example.com';
const testPassword = 'Test123!@#';
const testUsername = 'testuser';
const testVerificationCode = '123456';

// ========== CHALLENGES TEST DATA ==========

/// Sample challenge code response
final testChallengeCode = ChallengeCode(
  challengeCode: 'TEST123',
  qr: 'https://example.com/qr/TEST123',
);

/// Sample challenge code string
const testChallengeCodeString = 'TEST123';

// ========== ERROR TEST DATA ==========

/// Sample error messages
const testErrorMessage = 'An error occurred';
const testNetworkErrorMessage = 'Network connection failed';
const testValidationErrorMessage = 'Invalid input';
const testAuthErrorMessage = 'Authentication failed';

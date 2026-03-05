// Mock Firebase Database references and streams for testing
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:mocktail/mocktail.dart';

/// Mock Firebase Database for testing
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

/// Mock Database Reference for testing
class MockDatabaseReference extends Mock implements DatabaseReference {}

/// Mock Database Event for testing
class MockDatabaseEvent extends Mock implements DatabaseEvent {}

/// Mock Data Snapshot for testing
class MockDataSnapshot extends Mock implements DataSnapshot {}

/// Mock Query for testing Firebase queries
class MockQuery extends Mock implements Query {}

/// Helper to create a fake DatabaseEvent with data
DatabaseEvent createFakeDatabaseEvent({
  required DataSnapshot snapshot,
  DatabaseEventType type = DatabaseEventType.value,
}) {
  final event = MockDatabaseEvent();
  when(() => event.snapshot).thenReturn(snapshot);
  when(() => event.type).thenReturn(type);
  return event;
}

/// Helper to create a fake DataSnapshot with value
DataSnapshot createFakeSnapshot({
  required dynamic value,
  required String key,
  bool exists = true,
}) {
  final snapshot = MockDataSnapshot();
  when(() => snapshot.value).thenReturn(value);
  when(() => snapshot.key).thenReturn(key);
  when(() => snapshot.exists).thenReturn(exists);
  return snapshot;
}

/// Helper to create a stream of DatabaseEvents for testing Firebase listeners
Stream<DatabaseEvent> createMockDatabaseStream({
  required List<Map<String, dynamic>> events,
  Duration delay = const Duration(milliseconds: 100),
}) {
  final controller = StreamController<DatabaseEvent>();

  Future.delayed(Duration.zero, () async {
    for (final eventData in events) {
      await Future.delayed(delay);
      final snapshot = createFakeSnapshot(
        value: eventData['value'],
        key: eventData['key'] as String,
        exists: eventData['exists'] as bool? ?? true,
      );
      final event = createFakeDatabaseEvent(snapshot: snapshot);
      controller.add(event);
    }
  });

  return controller.stream;
}

/// Helper to setup a mock DatabaseReference with a stream
void setupMockDatabaseReference(
  MockDatabaseReference mockRef,
  Stream<DatabaseEvent> stream,
) {
  when(() => mockRef.onValue).thenAnswer((_) => stream);
  when(() => mockRef.onChildAdded).thenAnswer((_) => stream);
  when(() => mockRef.onChildChanged).thenAnswer((_) => stream);
  when(() => mockRef.onChildRemoved).thenAnswer((_) => stream);
}

/// Helper to setup a mock DatabaseReference.set() call
void setupMockDatabaseSet(
  MockDatabaseReference mockRef, {
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    when(() => mockRef.set(any())).thenAnswer((_) async => {});
  } else {
    when(() => mockRef.set(any())).thenThrow(
      FirebaseException(
        plugin: 'firebase_database',
        code: 'permission-denied',
        message: 'Permission denied',
      ),
    );
  }
}

/// Helper to setup a mock DatabaseReference.update() call
void setupMockDatabaseUpdate(
  MockDatabaseReference mockRef, {
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    when(() => mockRef.update(any())).thenAnswer((_) async => {});
  } else {
    when(() => mockRef.update(any())).thenThrow(
      FirebaseException(
        plugin: 'firebase_database',
        code: 'permission-denied',
        message: 'Permission denied',
      ),
    );
  }
}

/// Helper to setup a mock DatabaseReference.remove() call
void setupMockDatabaseRemove(
  MockDatabaseReference mockRef, {
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    when(() => mockRef.remove()).thenAnswer((_) async => {});
  } else {
    when(() => mockRef.remove()).thenThrow(
      FirebaseException(
        plugin: 'firebase_database',
        code: 'permission-denied',
        message: 'Permission denied',
      ),
    );
  }
}

/// Helper to setup a mock DatabaseReference.once() call
void setupMockDatabaseOnce(
  MockDatabaseReference mockRef,
  DataSnapshot snapshot,
) {
  final event = createFakeDatabaseEvent(snapshot: snapshot);
  when(() => mockRef.once()).thenAnswer((_) async => event);
}

/// Helper to setup mock Firebase Database with paths
void setupMockFirebaseDatabase(
  MockFirebaseDatabase mockDb,
  Map<String, MockDatabaseReference> pathReferences,
) {
  pathReferences.forEach((path, ref) {
    when(() => mockDb.ref(path)).thenReturn(ref);
  });
}

/// Helper to create a mock challenge data structure
Map<String, dynamic> createMockChallengeData({
  required String challengeCode,
  required String status,
  int currentIndex = 0,
  List<dynamic>? questions,
  Map<String, dynamic>? participants,
}) {
  return {
    'meta': {
      'challengeCode': challengeCode,
      'status': status,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'createdBy': 'test-user-id',
      'title': 'Test Challenge',
    },
    'current': {
      'index': currentIndex,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    },
    'questions': questions ??
        [
          {
            'id': 'q1',
            'question': 'Test question?',
            'options': ['A', 'B', 'C', 'D'],
            'correctAnswer': 0,
            'timeLimit': 30,
          }
        ],
    'participants': participants ?? {},
    'leaderboard': [],
    'answers': {},
  };
}

/// Helper to create mock participant data
Map<String, dynamic> createMockParticipantData({
  required String userId,
  required String username,
  String? avatar,
  int score = 0,
}) {
  return {
    'userId': userId,
    'username': username,
    'avatar': avatar,
    'score': score,
    'rank': 1,
    'answers': {},
    'joinedAt': DateTime.now().millisecondsSinceEpoch,
    'status': 'active',
  };
}

/// Helper to create mock quiz data
Map<String, dynamic> createMockQuizData({
  required String quizId,
  required String chapterId,
  List<dynamic>? questions,
}) {
  return {
    'quizId': quizId,
    'chapterId': chapterId,
    'questions': questions ??
        [
          {
            'id': 'q1',
            'question': 'Test question?',
            'options': ['A', 'B', 'C', 'D'],
            'correctAnswer': 0,
            'explanation': 'Test explanation',
          }
        ],
    'createdAt': DateTime.now().toIso8601String(),
  };
}

import 'package:hive/hive.dart';

part 'UserModel.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String profilePicture;

  @HiveField(4)
  final int streak;

  @HiveField(5)
  final bool verified;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.profilePicture,
    required this.streak,
    required this.verified,
  });

  // Add these methods for Hive
  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'profilePicture': profilePicture,
    'streak': streak,
    'verified': verified,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['user_id'],
    email: json['email'],
    username: json['username'],
    profilePicture: json['profilePicture'],
    streak: json['streak'],
    verified: json['verified'],
  );
}

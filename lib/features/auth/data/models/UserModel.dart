class UserModel {
  final String id;

  final String email;

  final String username;

  final String profilePicture;

  final int streak;
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

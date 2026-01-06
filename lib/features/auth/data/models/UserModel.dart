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
    id: json['user_id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    profilePicture: json['profilePicture']?.toString() ?? '',
    streak: json['streak'] is int
        ? json['streak']
        : (int.tryParse(json['streak']?.toString() ?? '0') ?? 0),
    verified: json['verified'] is bool
        ? json['verified']
        : (json['verified']?.toString().toLowerCase() == 'true'),
  );
}

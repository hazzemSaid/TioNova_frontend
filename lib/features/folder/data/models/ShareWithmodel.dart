import 'package:equatable/equatable.dart';

class ShareWithmodel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String profilePicture;
  const ShareWithmodel({
    required this.id,
    required this.email,
    required this.username,
    required this.profilePicture,
  });

  factory ShareWithmodel.fromJson(Map<String, dynamic> json) {
    return ShareWithmodel(
      id: json['_id'],
      email: json['email'],
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'profilePicture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [id, email, username, profilePicture];
  @override
  String toString() {
    return 'ShareWithmodel(id: $id, email: $email, username: $username, profilePicture: $profilePicture)';
  }
}

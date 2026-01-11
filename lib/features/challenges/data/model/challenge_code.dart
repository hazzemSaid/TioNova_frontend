/*  "challengeCode": "C3D422",
    "qr": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKTSURBVO3BQY6sCAwFwXwW979yTu3GKyQEVP+yHBE/WGMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRrl4KYkfJNKl4QzKl0Szqh0SfgmlTuKNUqxRinWKAcPU3lSEv4lKk9KwpOKNUqxRinWKAcvS8IVKneodEnoVJ6UhCtU3lSsUYo1SrFGOfhxKut/xRqlWKMUa5SDH5eETuVMEs6o/LJijVKsUYo1ysHLVN6kckblTSr/kmKNUqxRijXKwcOS8E1J6FS6JHQqXRI6lTNJ+JcVa5RijVKsUeIHgyThjMpkxRqlWKMUa5SDm5LQqZxJwptUuiR0SehUuiR0KmeS0Kl0SbhC5Y5ijVKsUYo1SvzgQUnoVLokdCrflIQrVLokPEnlScUapVijFGuUg5cloVPpktCpdEk4o3ImCVeoXKHSJeEvFWuUYo1SrFHiBzck4YxKl4ROpUtCp9Il4YzKFUl4k0qXhE7lScUapVijFGuU+MGDktCp3JGETqVLQqdyJglvUumScIXKHcUapVijFGuU+MEPS8IZlTNJuELljiR0Kk8q1ijFGqVYoxzclIRvUjmj0iXhjMokxRqlWKMUa5SDh6k8KQlXJKFTuSMJncoVSfimYo1SrFGKNcrBy5JwhcpfSsIVSehUzqh0SehU7ijWKMUapVijHAyXhE6lS8JfUnlSsUYp1ijFGuXgx6mcSUKXhCtUuiRcodIl4YzKHcUapVijFGuUg5ep/BKVMypXJOGMypOKNUqxRinWKAcPS8I3JeEKlS4JXRI6lS4JZ1T+UrFGKdYoxRolfrDGKNYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1yn/gAPfaVLDxVQAAAABJRU5ErkJggg==",*/
import 'package:equatable/equatable.dart';
import 'package:tionova/features/challenges/domain/entities/Ichallenge_code.dart';

class ChallengeCode extends IChallengeCode implements Equatable {
  ChallengeCode({required super.challengeCode, required super.qr});
  @override
  List<Object?> get props => [challengeCode, qr];

  @override
  String toString() {
    return 'ChallengeCode(challengeCode: $challengeCode, qr: $qr)';
  }

  /// Factory constructor with null safety and validation
  factory ChallengeCode.fromJson(Map<String, dynamic> json) {
    final challengeCode = json['challengeCode'];
    final qr = json['qr'];

    // Validate challengeCode is not null or empty
    if (challengeCode == null ||
        (challengeCode is String && challengeCode.isEmpty)) {
      throw FormatException(
        'Invalid challenge code: challengeCode is null or empty',
      );
    }

    // Validate qr is not null or empty
    if (qr == null || (qr is String && qr.isEmpty)) {
      throw FormatException('Invalid challenge code: qr is null or empty');
    }

    return ChallengeCode(
      challengeCode: challengeCode as String,
      qr: qr as String,
    );
  }

  /// Check if the challenge code is valid
  bool get isValid => challengeCode.isNotEmpty && qr.isNotEmpty;

  @override
  bool? get stringify => true;
}

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

  factory ChallengeCode.fromJson(Map<String, dynamic> json) {
    return ChallengeCode(
      challengeCode: json['challengeCode'] as String,
      qr: json['qr'] as String,
    );
  }

  @override
  bool? get stringify => true;
}

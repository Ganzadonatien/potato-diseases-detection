import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final bool approved;
  final String province;
  final String district;
  final String sector;
  final DateTime createdAt;
  final String? profileImageUrl;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.approved,
    required this.province,
    required this.district,
    required this.sector,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime createdAt = DateTime.now().toUtc();

    if (createdAtRaw is String) {
      createdAt = DateTime.parse(createdAtRaw).toUtc();
    } else if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate().toUtc();
    }

    return UserProfile(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      approved: json['approved'] as bool? ?? true,
      province: json['province'] as String,
      district: json['district'] as String,
      sector: json['sector'] as String,
      createdAt: createdAt,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'approved': approved,
      'province': province,
      'district': district,
      'sector': sector,
      'createdAt': createdAt.toUtc().toIso8601String(),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  String get locationLabel => '$province · $district · $sector';
}

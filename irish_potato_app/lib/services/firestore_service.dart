import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('reports');

  Future<void> saveUserProfile(UserProfile profile) async {
    print('Saving profile to Firestore: uid=${profile.uid}');
    try {
      await _users.doc(profile.uid).set(profile.toJson());
      print('Firestore write successful');
    } catch (e, stackTrace) {
      print('Firestore write FAILED: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateProfileImage(String uid, String imageUrl) async {
    await _users.doc(uid).update({'profileImageUrl': imageUrl});
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _users.doc(user.uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;

    final data = Map<String, dynamic>.from(snapshot.data()!);
    data['uid'] = snapshot.id;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;

    final data = Map<String, dynamic>.from(snapshot.data()!);
    data['uid'] = snapshot.id;
    return UserProfile.fromJson(data);
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      final data = Map<String, dynamic>.from(snapshot.data()!);
      data['uid'] = snapshot.id;
      return UserProfile.fromJson(data);
    });
  }

  Stream<List<UserProfile>> getAllUsersStream() {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['uid'] = doc.id;
        return UserProfile.fromJson(data);
      }).toList();
    });
  }

  Future<List<UserProfile>> getPendingAgronomists() async {
    final snapshot = await _users
        .where('role', isEqualTo: 'agronomist')
        .where('approved', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['uid'] = doc.id;
      return UserProfile.fromJson(data);
    }).toList();
  }

  Future<void> approveAgronomist(String uid) async {
    await _users.doc(uid).update({'approved': true});
  }

  Future<List<UserProfile>> getFarmersNearby(UserProfile agronomist) async {
    if (agronomist.province.isEmpty ||
        agronomist.district.isEmpty ||
        agronomist.sector.isEmpty) {
      return [];
    }

    final snapshot = await _users
        .where('role', isEqualTo: 'farmer')
        .where('province', isEqualTo: agronomist.province)
        .where('district', isEqualTo: agronomist.district)
        .where('sector', isEqualTo: agronomist.sector)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['uid'] = doc.id;
      return UserProfile.fromJson(data);
    }).toList();
  }

  Future<List<LocationReportItem>> getReportsForLocation(
    UserProfile agronomist,
  ) async {
    final farmers = await getFarmersNearby(agronomist);
    if (farmers.isEmpty) {
      return [];
    }

    final reportGroups = await Future.wait(
      farmers.map((farmer) async {
        final reports = await getReportsForUser(farmer.uid);
        return reports.map((report) {
          return LocationReportItem(
            report: report,
            farmerName: farmer.fullName,
            farmerLocation: farmer.locationLabel,
          );
        }).toList();
      }),
    );

    final reports = reportGroups.expand((group) => group).toList();
    reports.sort((a, b) => b.report.createdAt.compareTo(a.report.createdAt));
    return reports;
  }

  Future<void> saveReport(ScanReport report, String userId) async {
    final data = report.toJson();
    data['userId'] = userId;
    await _reports.doc(report.id).set(data);
  }

  Future<List<ScanReport>> getReportsForUser(String userId) async {
    final snapshot = await _reports
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return ScanReport.fromJson(data);
    }).toList();
  }

  Future<void> addAdviceToReport(
    String reportId,
    String advice,
    String agronomistName,
  ) async {
    await _reports.doc(reportId).update({
      'advice': advice,
      'adviceBy': agronomistName,
      'adviceCreatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

class LocationReportItem {
  final ScanReport report;
  final String farmerName;
  final String farmerLocation;

  LocationReportItem({
    required this.report,
    required this.farmerName,
    required this.farmerLocation,
  });
}

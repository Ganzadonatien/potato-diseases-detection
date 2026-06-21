import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static int _notificationId = 0;
  static Function(String)? onNotificationTap;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          onNotificationTap?.call(response.payload!);
        }
      },
    );
  }

  static Future<void> showNotification(
    String title,
    String body,
    Map<String, dynamic> payload,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      _notificationId++,
      title,
      body,
      details,
      payload: jsonEncode(payload),
    );
  }

  static void listenToScanNotifications(String userId) async {
    // Only listen for own scan completions and advice updates
    FirebaseFirestore.instance
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null && data['advice'] != null && data['advice'] != '') {
            showNotification(
              'Agronomist Advice Received',
              'Your scan has new advice from ${data['adviceBy']}',
              {'type': 'advice_received', 'reportId': change.doc.id},
            );
          }
        }
      }
    }, onError: (error) {
      print('Firestore scan notifications error: $error');
    });
  }

  static void listenToFarmerScans() async {
    // Agronomists listen for new scans in their area
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) return;
    final userData = userDoc.data();
    if (userData == null || userData['role'] != 'agronomist') return;

    final province = userData['province'];
    final district = userData['district'];
    final sector = userData['sector'];

    FirebaseFirestore.instance
        .collection('notifications')
        .where('type', isEqualTo: 'farmer_scan')
        .where('province', isEqualTo: province)
        .where('district', isEqualTo: district)
        .where('sector', isEqualTo: sector)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            showNotification(
              data['title'] ?? 'New Scan Alert',
              data['body'] ?? 'A farmer needs your help',
              {
                'type': 'farmer_scan',
                'reportId': data['reportId'],
                'farmerId': data['farmerId'],
              },
            );
          }
        }
      }
    }, onError: (error) {
      print('Firestore farmer scans error: $error');
    });
  }

  static void listenToChatMessages(String userId) {
    FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _getSenderName(data['senderId']).then((senderName) {
              showNotification(
                'New message from $senderName',
                data['message'] ?? '',
                {
                  'type': 'chat_message',
                  'senderId': data['senderId'],
                  'senderName': senderName,
                },
              );
            });
          }
        }
      }
    });
  }

  static void listenToAdviceRequests() async {
    // Agronomists listen for advice requests in their area
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) return;
    final userData = userDoc.data();
    if (userData == null || userData['role'] != 'agronomist') return;

    final province = userData['province'];
    final district = userData['district'];
    final sector = userData['sector'];

    FirebaseFirestore.instance
        .collection('notifications')
        .where('type', isEqualTo: 'advice_request')
        .where('province', isEqualTo: province)
        .where('district', isEqualTo: district)
        .where('sector', isEqualTo: sector)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            showNotification(
              data['title'] ?? 'Advice Requested',
              data['body'] ?? 'A farmer needs your advice',
              {
                'type': 'advice_request',
                'reportId': data['reportId'],
                'farmerId': data['farmerId'],
              },
            );
          }
        }
      }
    }, onError: (error) {
      print('Firestore advice requests error: $error');
    });
  }

  static Future<String> _getSenderName(String senderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();
      return doc.data()?['fullName'] ?? 'Someone';
    } catch (e) {
      return 'Someone';
    }
  }

  static void startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      listenToScanNotifications(user.uid);
      listenToChatMessages(user.uid);
      listenToFarmerScans();
      listenToAdviceRequests();
    }
  }

  static void stopListening() {
    // Listeners will be cleaned up automatically when app closes
  }
}

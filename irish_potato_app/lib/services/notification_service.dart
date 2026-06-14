import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  static Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        notification.title ?? 'Notification',
        notification.body ?? '',
        message.data,
      );
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Navigation handled in main.dart
  }

  static Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, details, payload: data.toString());
  }

  static Future<void> sendNotificationToAgronomists(
    String province,
    String district,
    String sector,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final agronomists = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'agronomist')
        .where('province', isEqualTo: province)
        .where('district', isEqualTo: district)
        .where('sector', isEqualTo: sector)
        .get();

    for (var doc in agronomists.docs) {
      final token = doc.data()['fcmToken'];
      if (token != null) {
        await _sendToToken(token, title, body, data);
      }
    }
  }

  static Future<void> sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final token = userDoc.data()?['fcmToken'];
    if (token != null) {
      await _sendToToken(token, title, body, data);
    }
  }

  static Future<void> _sendToToken(
    String token,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'token': token,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }
}

import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/splash_screen.dart';
import 'package:irish_potato_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irish_potato_app/wrapper.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:irish_potato_app/services/local_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/screens/scan_history_screen.dart';
import 'package:irish_potato_app/screens/farmer_advice_screen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:irish_potato_app/screens/chat_screen.dart';
import 'package:irish_potato_app/screens/agronomist_farmers_screen.dart';
import 'dart:convert';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.initialize();
  
  LocalNotificationService.onNotificationTap = (payload) {
    _handleNotificationTap(payload);
  };
  
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      LocalNotificationService.startListening();
    }
  });
  
  runApp(const MyApp());
}

void _handleNotificationTap(String payload) async {
  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final type = data['type'];
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (type == 'scan_complete' || type == 'advice_received') {
      Get.to(() => const ScanHistoryScreen());
    } else if (type == 'chat_message') {
      final senderId = data['senderId'];
      if (currentUser != null && senderId != null) {
        final otherUserProfile = await FirestoreService().getUserProfile(senderId);
        final currentUserProfile = await FirestoreService().getUserProfile(currentUser.uid);
        if (otherUserProfile != null && currentUserProfile != null) {
          Get.to(() => ChatScreen(
            currentUser: currentUserProfile,
            otherUser: otherUserProfile,
          ));
        }
      }
    } else if (type == 'advice_request' || type == 'farmer_scan') {
      if (currentUser != null) {
        final userProfile = await FirestoreService().getUserProfile(currentUser.uid);
        if (userProfile != null && userProfile.role == 'Agronomist') {
          final farmerId = data['farmerId'];
          if (farmerId != null) {
            final farmerProfile = await FirestoreService().getUserProfile(farmerId);
            if (farmerProfile != null) {
              Get.to(() => AgronomistFarmerReportsScreen(farmer: farmerProfile));
            }
          }
        } else {
          Get.to(() => const FarmerAdviceScreen());
        }
      }
    }
  } catch (e) {
    print('Error handling notification tap: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(debugShowCheckedModeBanner: false,
    theme: LightMode,
     home: SplashScreen(),
     );
  }
}

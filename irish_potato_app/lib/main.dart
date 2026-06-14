import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/splash_screen.dart';
import 'package:irish_potato_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irish_potato_app/wrapper.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:irish_potato_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      NotificationService.saveTokenToFirestore(user.uid);
    }
  });
  
  runApp(const MyApp());
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

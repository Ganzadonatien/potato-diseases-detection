import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/splash_screen.dart';
import 'package:irish_potato_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irish_potato_app/wrapper.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(debugShowCheckedModeBanner: false,
    theme: LightMode,
     home: Wrapper(),
     );
  }
}

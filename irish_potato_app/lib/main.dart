import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/splash_screen.dart';
import 'dart:async';
import 'package:irish_potato_app/theme/theme.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
    theme: LightMode,
     home: SplashScreen());
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/screens/dashboard.dart';
import 'package:irish_potato_app/screens/admin_dashboard.dart';
import 'package:irish_potato_app/screens/login.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          // Use StreamBuilder instead of FutureBuilder to get real-time updates
          return StreamBuilder(
            stream: FirestoreService().getUserProfileStream(snapshot.data!.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final profile = profileSnapshot.data;
              if (profile?.role == 'admin') {
                return const AdminDashboard();
              }
              return const MainDashboard();
            },
          );
        }
        
        return const SignInScreen();
      },
    );
  }
}

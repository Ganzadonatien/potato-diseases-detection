import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/home_screen.dart';
import 'package:irish_potato_app/screens/captureScreen.dart';
import 'package:irish_potato_app/screens/scan_history_screen.dart';
import 'package:irish_potato_app/screens/advice_history_screen.dart';
import 'package:irish_potato_app/screens/analytics_dashboard.dart';
import 'package:irish_potato_app/screens/farmer_reports_screen.dart';
import 'package:irish_potato_app/screens/profile_screen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await FirestoreService().getUserProfile(uid);
      setState(() {
        _userProfile = profile;
      });
    }
  }

  List<Widget> _getScreens() {
    if (_userProfile?.role == 'agronomist') {
      return [
        const HomeScreen(),
        const AdviceHistoryScreen(),
        const CaptureScreen(),
        const FarmerReportsScreen(),
        const ProfileScreen(),
      ];
    }
    // Default for farmers
    return [
      const HomeScreen(),
      const ScanHistoryScreen(),
      const CaptureScreen(),
      const AnalyticsDashboard(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = _getScreens();

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined, size: 32),
              activeIcon: Icon(Icons.camera_alt, size: 32),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

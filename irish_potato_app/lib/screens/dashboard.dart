import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/screens/admin_approval_screen.dart';
import 'package:irish_potato_app/screens/agronomist_farmers_screen.dart';
import 'package:irish_potato_app/screens/captureScreen.dart';
import 'package:irish_potato_app/screens/farmer_advice_screen.dart';
import 'package:irish_potato_app/screens/analytics_dashboard.dart';
import 'package:irish_potato_app/screens/login.dart';
import 'package:irish_potato_app/screens/scan_history_screen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = FirestoreService().getCurrentUserProfile();
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MAIN DASHBOARD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final profile = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, ${user.displayName ?? user.email}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A2E1A),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile != null)
                  Text(
                    profile.locationLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                const SizedBox(height: 32),
                _DashboardButton(
                  label: 'Capture Leaf',
                  color: const Color(0xFF1B5E3A),
                  icon: Icons.camera_alt_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaptureScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                if (profile?.role == 'farmer') ...[
                  _DashboardButton(
                    label: 'Agronomist Advice',
                    color: const Color(0xFF6A4E99),
                    icon: Icons.support_agent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmerAdviceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
                if (profile?.role == 'agronomist') ...[
                  if (profile!.approved) ...[
                    _DashboardButton(
                      label: 'Farmers Nearby',
                      color: const Color(0xFF1C7A5B),
                      icon: Icons.group,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AgronomistFarmersScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ] else ...[
                    const Card(
                      color: Colors.white24,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Your agronomist account is pending admin approval. You will be able to access agronomist tools once approved.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
                if (profile?.role == 'admin') ...[
                  _DashboardButton(
                    label: 'Approve Agronomists',
                    color: const Color(0xFFBF360C),
                    icon: Icons.verified_user,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminApprovalScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
                _DashboardButton(
                  label: 'View Reports',
                  color: const Color(0xFF8B1A1A),
                  icon: Icons.bar_chart_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsDashboard(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                _DashboardButton(
                  label: 'View History',
                  color: const Color(0xFF1A2260),
                  icon: Icons.trending_up_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signout,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.logout_rounded),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

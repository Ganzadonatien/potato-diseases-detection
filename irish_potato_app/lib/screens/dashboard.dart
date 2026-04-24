import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/captureScreen.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome, John',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A2E1A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
           _DashboardButton(
  label: 'Capture Leaf',
  color: const Color(0xFF1B5E3A),
  icon: Icons.camera_alt_outlined,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  },
),
            const SizedBox(height: 30),
            _DashboardButton(
              label: 'View Reports',
              color: const Color(0xFF8B1A1A),
              icon: Icons.bar_chart_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 30),
            _DashboardButton(
              label: 'View History',
              color: const Color(0xFF1A2260),
              icon: Icons.trending_up_rounded,
              onTap: () {},
            ),
          ],
        ),
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
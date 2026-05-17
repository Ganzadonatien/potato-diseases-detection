import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('System Analytics'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalUsers = usersSnapshot.data?.docs.length ?? 0;
          final farmers = usersSnapshot.data?.docs
                  .where((doc) => doc['role'] == 'farmer')
                  .length ??
              0;
          final agronomists = usersSnapshot.data?.docs
                  .where((doc) => doc['role'] == 'agronomist')
                  .length ??
              0;
          final admins = usersSnapshot.data?.docs
                  .where((doc) => doc['role'] == 'admin')
                  .length ??
              0;
          final pending = usersSnapshot.data?.docs
                  .where((doc) =>
                      doc['role'] == 'agronomist' &&
                      doc['approved'] == false)
                  .length ??
              0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (context, reportsSnapshot) {
              final totalScans = reportsSnapshot.data?.docs.length ?? 0;
              final healthyScans = reportsSnapshot.data?.docs
                      .where((doc) => doc['diseaseName'] == 'None')
                      .length ??
                  0;
              final diseasedScans = totalScans - healthyScans;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _StatCard(
                      title: 'Total Users',
                      value: totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Farmers',
                            value: farmers.toString(),
                            icon: Icons.person,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Agronomists',
                            value: agronomists.toString(),
                            icon: Icons.local_hospital,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Admins',
                            value: admins.toString(),
                            icon: Icons.admin_panel_settings,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Pending Approval',
                            value: pending.toString(),
                            icon: Icons.pending,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Scan Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _StatCard(
                      title: 'Total Scans',
                      value: totalScans.toString(),
                      icon: Icons.camera_alt,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Healthy',
                            value: healthyScans.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Diseased',
                            value: diseasedScans.toString(),
                            icon: Icons.warning,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Platform Health',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _HealthRow(
                            label: 'User Engagement',
                            value: totalUsers > 0 ? 'Active' : 'Low',
                            color: totalUsers > 0 ? Colors.green : Colors.red,
                          ),
                          const Divider(),
                          _HealthRow(
                            label: 'Scan Activity',
                            value: totalScans > 0 ? 'Active' : 'Low',
                            color: totalScans > 0 ? Colors.green : Colors.red,
                          ),
                          const Divider(),
                          _HealthRow(
                            label: 'Pending Approvals',
                            value: pending > 0 ? 'Needs Attention' : 'Clear',
                            color: pending > 0 ? Colors.orange : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HealthRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

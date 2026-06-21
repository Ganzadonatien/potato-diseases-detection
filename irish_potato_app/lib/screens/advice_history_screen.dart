import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class AdviceHistoryScreen extends StatefulWidget {
  const AdviceHistoryScreen({super.key});

  @override
  State<AdviceHistoryScreen> createState() => _AdviceHistoryScreenState();
}

class _AdviceHistoryScreenState extends State<AdviceHistoryScreen> {
  late final Future<List<ScanReport>> _adviceHistoryFuture;

  @override
  void initState() {
    super.initState();
    _adviceHistoryFuture = _loadAdviceHistory();
  }

  Future<List<ScanReport>> _loadAdviceHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final profile = await FirestoreService().getUserProfile(user.uid);
    if (profile == null || profile.fullName.isEmpty) return [];

    return FirestoreService().getAdviceHistoryForAgronomist(profile.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFF2E7D32),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advice History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track advice you\'ve given to farmers',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ScanReport>>(
              future: _adviceHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading advice history: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  );
                }

                final adviceReports = snapshot.data ?? [];
                if (adviceReports.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No advice history yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Advice you send to farmers will appear here once it is saved.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: adviceReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final report = adviceReports[index];
                    final adviceTime =
                        report.adviceCreatedAt ?? report.createdAt;
                    final formattedDate = DateFormat(
                      'MMM d, yyyy • hh:mm a',
                    ).format(adviceTime.toLocal());

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              report.diseaseName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              report.advice ?? 'No advice text available.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (report.adviceBy != null &&
                                    report.adviceBy!.isNotEmpty)
                                  Text(
                                    'By ${report.adviceBy}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

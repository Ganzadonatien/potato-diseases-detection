import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/screens/captureScreen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:irish_potato_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerAdviceScreen extends StatefulWidget {
  const FarmerAdviceScreen({super.key});

  @override
  State<FarmerAdviceScreen> createState() => _FarmerAdviceScreenState();
}

class _FarmerAdviceScreenState extends State<FarmerAdviceScreen> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = FirestoreService().getCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        elevation: 0,
        centerTitle: true,
        title: const Text('Agronomist Advice'),
      ),
      body: SafeArea(
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Unable to load your profile.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final profile = snapshot.data!;

            return FutureBuilder<List<ScanReport>>(
              future: FirestoreService().getReportsForUser(profile.uid),
              builder: (context, reportSnapshot) {
                if (reportSnapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (reportSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading advice: ${reportSnapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final reports = reportSnapshot.data ?? [];

                if (reports.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'No advice yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You have no scan reports saved in the cloud yet. Capture a leaf to receive agronomist treatment advice.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E3A),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CaptureScreen(),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          child: const Text('Capture Leaf Now'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final hasAdvice = report.advice != null && report.advice!.isNotEmpty;
                    
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScanResultScreen(report: report),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                report.diseaseName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasAdvice
                                    ? report.advice!
                                    : 'Waiting for agronomist advice.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasAdvice ? Colors.black87 : Colors.black54,
                                ),
                              ),
                              if (report.adviceBy != null &&
                                  report.adviceBy!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Advice by ${report.adviceBy}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Text(
                                'Captured: ${report.createdAt.toLocal().toString().split('.').first}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                              if (!hasAdvice) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9800),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await NotificationService.sendNotificationToAgronomists(
                                        profile.province,
                                        profile.district,
                                        profile.sector,
                                        'Advice Requested',
                                        '${profile.fullName} needs advice for ${report.diseaseName}',
                                        {'type': 'advice_request', 'reportId': report.id, 'farmerId': profile.uid},
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Agronomists notified! They will review your scan soon.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.notifications_active),
                                    label: const Text('Remind Agronomist'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

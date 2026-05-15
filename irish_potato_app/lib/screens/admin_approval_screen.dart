import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  late Future<List<UserProfile>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _pendingFuture = FirestoreService().getPendingAgronomists();
  }

  Future<void> _refreshPending() async {
    setState(() {
      _pendingFuture = FirestoreService().getPendingAgronomists();
    });
  }

  Future<void> _approveAgronomist(String uid) async {
    await FirestoreService().approveAgronomist(uid);
    await _refreshPending();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Agronomist approved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        elevation: 0,
        centerTitle: true,
        title: const Text('Approve Agronomists'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<UserProfile>>(
          future: _pendingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load pending requests: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final pending = snapshot.data ?? [];
            if (pending.isEmpty) {
              return const Center(
                child: Text(
                  'No pending agronomist approval requests.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshPending,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: pending.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final profile = pending[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.locationLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E3A),
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  onPressed: () async {
                                    await _approveAgronomist(profile.uid);
                                  },
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

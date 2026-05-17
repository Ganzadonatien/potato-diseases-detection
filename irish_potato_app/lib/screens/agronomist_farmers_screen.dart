import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class AgronomistFarmersScreen extends StatefulWidget {
  const AgronomistFarmersScreen({super.key});

  @override
  State<AgronomistFarmersScreen> createState() =>
      _AgronomistFarmersScreenState();
}

class _AgronomistFarmersScreenState extends State<AgronomistFarmersScreen> {
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
        title: const Text('Farmers Nearby'),
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
                  'Unable to load agronomist profile.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final agronomist = snapshot.data!;
            return FutureBuilder<List<UserProfile>>(
              future: FirestoreService().getFarmersNearby(agronomist),
              builder: (context, farmerSnapshot) {
                if (farmerSnapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (farmerSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load farmers: ${farmerSnapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final farmers = farmerSnapshot.data ?? [];

                if (farmers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No farmers found in your area.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Make sure your signup location is correct: ${agronomist.locationLabel}.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E3A),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View all location reports'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AgronomistLocationReportsScreen(
                                    agronomist: agronomist,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: farmers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final farmer = farmers[index];
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
                                        AgronomistFarmerReportsScreen(
                                          farmer: farmer,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      farmer.fullName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      farmer.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      farmer.locationLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AgronomistFarmerReportsScreen extends StatefulWidget {
  final UserProfile farmer;

  const AgronomistFarmerReportsScreen({super.key, required this.farmer});

  @override
  State<AgronomistFarmerReportsScreen> createState() =>
      _AgronomistFarmerReportsScreenState();
}

class _AgronomistFarmerReportsScreenState
    extends State<AgronomistFarmerReportsScreen> {
  late Future<List<ScanReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = FirestoreService().getReportsForUser(widget.farmer.uid);
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reportsFuture = FirestoreService().getReportsForUser(widget.farmer.uid);
    });
  }

  Future<void> _showAdviceDialog(ScanReport report) async {
    final controller = TextEditingController(text: report.advice ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Advice'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Describe the treatment or recommendations for this farmer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final advice = controller.text.trim();
                if (advice.isEmpty) return;
                final profile = await FirestoreService()
                    .getCurrentUserProfile();
                final by = profile?.fullName ?? 'Agronomist';
                await FirestoreService().addAdviceToReport(
                  report.id,
                  advice,
                  by,
                );
                if (!mounted) return;
                Navigator.of(this.context).pop();
                await _refreshReports();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        elevation: 0,
        centerTitle: true,
        title: Text('Reports for ${widget.farmer.fullName}'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ScanReport>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load reports: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'No reports found for this farmer yet.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ask the farmer to scan a leaf. When a report arrives you can send treatment advice directly from this screen.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshReports,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 6),
                          Text(
                            'Captured: ${report.createdAt.toLocal().toString().split('.').first}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (report.advice != null &&
                              report.advice!.isNotEmpty) ...[
                            Text(
                              'Advice: ${report.advice!}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (report.adviceBy != null &&
                                report.adviceBy!.isNotEmpty)
                              Text(
                                'Sent by ${report.adviceBy}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ] else ...[
                            const Text(
                              'No advice yet. Tap below to send a recommendation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E3A),
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  onPressed: () => _showAdviceDialog(report),
                                  child: Text(
                                    report.advice == null ||
                                            report.advice!.isEmpty
                                        ? 'Send Advice'
                                        : 'Update Advice',
                                  ),
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

class AgronomistLocationReportsScreen extends StatefulWidget {
  final UserProfile agronomist;

  const AgronomistLocationReportsScreen({super.key, required this.agronomist});

  @override
  State<AgronomistLocationReportsScreen> createState() =>
      _AgronomistLocationReportsScreenState();
}

class _AgronomistLocationReportsScreenState
    extends State<AgronomistLocationReportsScreen> {
  late Future<List<LocationReportItem>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = FirestoreService().getReportsForLocation(
      widget.agronomist,
    );
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reportsFuture = FirestoreService().getReportsForLocation(
        widget.agronomist,
      );
    });
  }

  Future<void> _showAdviceDialog(ScanReport report) async {
    final controller = TextEditingController(text: report.advice ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Advice'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Describe the treatment or recommendations for this farmer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final advice = controller.text.trim();
                if (advice.isEmpty) return;
                final profile = await FirestoreService()
                    .getCurrentUserProfile();
                final by = profile?.fullName ?? 'Agronomist';
                await FirestoreService().addAdviceToReport(
                  report.id,
                  advice,
                  by,
                );
                if (!mounted) return;
                Navigator.of(this.context).pop();
                await _refreshReports();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        elevation: 0,
        centerTitle: true,
        title: Text('Location reports: ${widget.agronomist.locationLabel}'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<LocationReportItem>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load location reports: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Text(
                      'No reports found in your location yet.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Farmers from your area have not submitted any disease scans yet.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshReports,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = reports[index];
                  final report = item.report;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                            item.farmerName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.farmerLocation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
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
                          const SizedBox(height: 6),
                          Text(
                            'Captured: ${report.createdAt.toLocal().toString().split('.').first}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (report.advice != null &&
                              report.advice!.isNotEmpty) ...[
                            Text(
                              'Advice: ${report.advice!}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (report.adviceBy != null &&
                                report.adviceBy!.isNotEmpty)
                              Text(
                                'Sent by ${report.adviceBy}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ] else ...[
                            const Text(
                              'No advice yet. Tap below to send a recommendation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E3A),
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  onPressed: () => _showAdviceDialog(report),
                                  child: Text(
                                    report.advice == null ||
                                            report.advice!.isEmpty
                                        ? 'Send Advice'
                                        : 'Update Advice',
                                  ),
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

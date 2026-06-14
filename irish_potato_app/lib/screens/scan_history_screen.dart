import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/screens/captureScreen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  late final Future<List<ScanReport>> _reportsFuture;
  String? _selectedDisease;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _reportsFuture = FirestoreService().getReportsForUser(user.uid);
    } else {
      _reportsFuture = Future.value([]);
    }
  }

  List<ScanReport> _filterReports(List<ScanReport> reports) {
    return reports.where((report) {
      // Filter by disease
      if (_selectedDisease != null && _selectedDisease != 'All') {
        if (report.diseaseName != _selectedDisease) return false;
      }

      // Filter by date range
      if (_startDate != null) {
        if (report.createdAt.toLocal().isBefore(_startDate!)) return false;
      }
      if (_endDate != null) {
        final endOfDay = _endDate!.add(const Duration(days: 1));
        if (report.createdAt.toLocal().isAfter(endOfDay)) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  'Error loading history: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final allReports = snapshot.data ?? [];
            final filteredReports = _filterReports(allReports);
            
            // Debug info
            print('Total reports loaded: ${allReports.length}');
            allReports.forEach((r) {
              print('Report: ${r.diseaseName} at ${r.createdAt}');
            });

            return Column(
              children: [
                // Filters
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Disease filter
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: _selectedDisease,
                          hint: const Text('Filter by disease'),
                          items: <String?>[
                            null,
                            'All',
                            'None',
                            'Early Blight',
                            'Late Blight',
                            'Bacterial Wilt',
                            'Pest',
                          ].map((String? value) {
                            return DropdownMenuItem<String?>(
                              value: value,
                              child: Text(value ?? 'All Diseases'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDisease = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date range filter
                      ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                              : 'Select date range',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF5A7A5A),
                          minimumSize: const Size.fromHeight(45),
                        ),
                      ),
                      if (_startDate != null || _endDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          child: const Text(
                            'Clear date filter',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // History list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (filteredReports.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No records found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting your filters or capture a new leaf scan.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                      setState(() {
                                        _loadReports();
                                      });
                                    });
                                  },
                                  child: const Text('Capture Leaf'),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredReports.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScanResultScreen(report: report),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
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
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    report.diseaseName,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: _getColorForDisease(report.diseaseName),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getColorForDisease(report.diseaseName).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${(report.confidence * 100).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getColorForDisease(report.diseaseName),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          DateFormat('MMM d, yyyy - hh:mm a').format(report.createdAt.toLocal()),
                                          style: const TextStyle(
                                            fontSize: 13,
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getColorForDisease(String disease) {
    switch (disease) {
      case 'None':
        return const Color(0xFF2E7D32);
      case 'Early Blight':
        return const Color(0xFFFFA726);
      case 'Late Blight':
        return const Color(0xFFD32F2F);
      case 'Bacterial Wilt':
        return const Color(0xFF6D4C41);
      case 'Pest':
        return const Color(0xFF0288D1);
      default:
        return const Color(0xFF1B5E3A);
    }
  }
}

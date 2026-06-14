import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:irish_potato_app/screens/scan_history_screen.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFF5A7A5A),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A7A5A), Color(0xFF7A9A7A)],
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
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your potato leaf health statistics',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ScanReport>>(
              stream: FirestoreService().getReportsStream(FirebaseAuth.instance.currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];
                
                if (reports.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No scan data yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start scanning potato leaves to see analytics',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final totalScans = reports.length;
                final healthyCount = reports.where((r) => r.diseaseName == 'Healthy').length;
                final earlyBlightCount = reports.where((r) => r.diseaseName == 'Early-blight').length;
                final lateBlightCount = reports.where((r) => r.diseaseName == 'Late-blight').length;
                final bacterialWiltCount = reports.where((r) => r.diseaseName == 'Bacterial-wilt').length;
                final pestCount = reports.where((r) => r.diseaseName == 'Pest').length;

                final healthyPercentage = totalScans > 0 ? (healthyCount / totalScans * 100).toStringAsFixed(1) : '0';
                final diseasedCount = totalScans - healthyCount;
                final last7Days = _getLast7DaysData(reports);

                final diseaseData = [
                  {'name': 'Healthy', 'count': healthyCount, 'color': const Color(0xFF2E7D32)},
                  {'name': 'Early Blight', 'count': earlyBlightCount, 'color': const Color(0xFFFFA726)},
                  {'name': 'Late Blight', 'count': lateBlightCount, 'color': const Color(0xFFD32F2F)},
                  {'name': 'Bacterial Wilt', 'count': bacterialWiltCount, 'color': const Color(0xFF6D4C41)},
                  {'name': 'Pest', 'count': pestCount, 'color': const Color(0xFF0288D1)},
                ].where((d) => (d['count'] as int) > 0).toList();

                return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stats Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Scans',
                                value: totalScans.toString(),
                                icon: Icons.qr_code_scanner,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1B5E3A), Color(0xFF2E7D32)],
                                ),
                                onTap: _navigateToHistory,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Healthy',
                                value: healthyCount.toString(),
                                icon: Icons.check_circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                                ),
                                onTap: _navigateToHistory,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Diseased',
                                value: diseasedCount.toString(),
                                icon: Icons.warning_amber,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                                ),
                                onTap: _navigateToHistory,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Health Rate',
                                value: '$healthyPercentage%',
                                icon: Icons.pie_chart,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
                                ),
                                onTap: _navigateToHistory,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Multi-Line Chart Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Disease Trends (Last 7 Days)',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track each disease category over time',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 250,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 1,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey[300]!,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    last7Days[value.toInt()]['day'],
                                                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minY: 0,
                                      lineBarsData: _buildDiseaseLines(reports, last7Days),
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          tooltipBgColor: Colors.black87,
                                          getTooltipItems: (touchedSpots) {
                                            return touchedSpots.map((spot) {
                                              final diseaseNames = ['Healthy', 'Early Blight', 'Late Blight', 'Bacterial Wilt', 'Pest'];
                                              final diseaseName = spot.barIndex < diseaseNames.length ? diseaseNames[spot.barIndex] : 'Unknown';
                                              return LineTooltipItem(
                                                '$diseaseName\n${spot.y.toInt()} scans',
                                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              );
                                            }).toList();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Legend
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _LegendItem(color: const Color(0xFF2E7D32), label: 'Healthy'),
                                    _LegendItem(color: const Color(0xFFFFA726), label: 'Early Blight'),
                                    _LegendItem(color: const Color(0xFFD32F2F), label: 'Late Blight'),
                                    _LegendItem(color: const Color(0xFF6D4C41), label: 'Bacterial Wilt'),
                                    _LegendItem(color: const Color(0xFF0288D1), label: 'Pest'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Pie Chart Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Disease Distribution',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Overall breakdown of all scanned results',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 220,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: PieChart(
                                            PieChartData(
                                              sectionsSpace: 2,
                                              centerSpaceRadius: 35,
                                              sections: diseaseData.map((data) {
                                                final count = data['count'] as int;
                                                final percentage = (count / totalScans * 100).toStringAsFixed(1);
                                                return PieChartSectionData(
                                                  value: count.toDouble(),
                                                  title: '$percentage%',
                                                  color: data['color'] as Color,
                                                  radius: 45,
                                                  titleStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: diseaseData.map((data) {
                                            final name = data['name'] as String;
                                            final count = data['count'] as int;
                                            final color = data['color'] as Color;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                  Text(
                                                    '$count',
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getLast7DaysData(List<ScanReport> reports) {
    final now = DateTime.now();
    final days = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('EEE').format(date);
      
      final count = reports.where((r) {
        final reportDate = DateFormat('yyyy-MM-dd').format(r.createdAt.toLocal());
        return reportDate == dateKey;
      }).length;
      
      days.add({'day': dayLabel, 'count': count, 'date': dateKey});
    }
    
    return days;
  }

  List<LineChartBarData> _buildDiseaseLines(List<ScanReport> reports, List<Map<String, dynamic>> last7Days) {
    final diseases = [
      {'name': 'Healthy', 'color': const Color(0xFF2E7D32)},
      {'name': 'Early-blight', 'color': const Color(0xFFFFA726)},
      {'name': 'Late-blight', 'color': const Color(0xFFD32F2F)},
      {'name': 'Bacterial-wilt', 'color': const Color(0xFF6D4C41)},
      {'name': 'Pest', 'color': const Color(0xFF0288D1)},
    ];

    return diseases.map((disease) {
      final spots = <FlSpot>[];
      for (int i = 0; i < last7Days.length; i++) {
        final dateKey = last7Days[i]['date'];
        final count = reports.where((r) {
          final reportDate = DateFormat('yyyy-MM-dd').format(r.createdAt.toLocal());
          return reportDate == dateKey && r.diseaseName == disease['name'];
        }).length;
        spots.add(FlSpot(i.toDouble(), count.toDouble()));
      }

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: disease['color'] as Color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: disease['color'] as Color,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

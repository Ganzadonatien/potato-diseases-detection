import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/services/report_storage.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  late final Future<List<ScanReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ReportStorage().loadReports();
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
          'Analytics',
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading analytics: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final reports = snapshot.data ?? [];

            final totalScans = reports.length;

            final healthyCount = reports
                .where((r) => r.diseaseName == 'None')
                .length;

            final diseasedCount = totalScans - healthyCount;

            final healthyPercentage = totalScans > 0
                ? (healthyCount / totalScans * 100)
                      .toStringAsFixed(1)
                : '0.0';

            // Disease Breakdown
            final Map<String, int> diseaseBreakdown = {};

            for (var report in reports) {
              if (report.diseaseName != 'None') {
                diseaseBreakdown[report.diseaseName] =
                    (diseaseBreakdown[report.diseaseName] ?? 0) + 1;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Report Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Track your leaf scan statistics and health trends.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Total Scans Card
                  _StatCard(
                    title: 'Total Scans',
                    value: totalScans.toString(),
                    icon: Icons.image_rounded,
                    color: const Color(0xFF1B5E3A),
                  ),

                  const SizedBox(height: 16),

                  // Healthy Leaves Card
                  _StatCard(
                    title: 'Healthy Leaves',
                    value: '$healthyCount ($healthyPercentage%)',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF2E7D32),
                  ),

                  const SizedBox(height: 16),

                  // Diseased Leaves Card
                  _StatCard(
                    title: 'Diseased Leaves',
                    value: diseasedCount.toString(),
                    icon: Icons.warning_rounded,
                    color: const Color(0xFFD32F2F),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Disease Histogram',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: diseaseBreakdown.isNotEmpty
                        ? BarChart(
                            BarChartData(
                              alignment:
                                  BarChartAlignment.spaceAround,

                              maxY:
                                  diseaseBreakdown.values
                                          .reduce(
                                            (a, b) =>
                                                a > b ? a : b,
                                          )
                                          .toDouble() +
                                      2,

                              // Tooltip
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData:
                                    BarTouchTooltipData(
                                  tooltipBgColor:
                                      Colors.grey[800],
                                  tooltipRoundedRadius: 8,

                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    final disease =
                                        diseaseBreakdown.keys
                                            .toList()[groupIndex];

                                    return BarTooltipItem(
                                      '$disease\n${rod.toY.toInt()} scans',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Titles
                              titlesData: FlTitlesData(
                                show: true,

                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,

                                    getTitlesWidget:
                                        (value, meta) {
                                      final diseases =
                                          diseaseBreakdown.keys
                                              .toList();

                                      if (value.toInt() >= 0 &&
                                          value.toInt() <
                                              diseases.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            diseases[
                                                value.toInt()],
                                            style:
                                                const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                            textAlign:
                                                TextAlign.center,
                                          ),
                                        );
                                      }

                                      return const SizedBox();
                                    },
                                  ),
                                ),

                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,

                                    getTitlesWidget:
                                        (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),

                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                              ),

                              borderData: FlBorderData(
                                show: false,
                              ),

                              gridData: FlGridData(
                                show: true,
                              ),

                              // Bars
                              barGroups: List.generate(
                                diseaseBreakdown.length,
                                (index) {
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: diseaseBreakdown
                                            .values
                                            .toList()[index]
                                            .toDouble(),

                                        color:
                                            _getColorForDisease(
                                          diseaseBreakdown.keys
                                              .toList()[index],
                                        ),

                                        width: 20,

                                        borderRadius:
                                            BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No disease data',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 28),

                  if (diseaseBreakdown.isNotEmpty) ...[
                    const Text(
                      'Disease Breakdown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children:
                            diseaseBreakdown.entries.map(
                          (entry) {
                            final percentage =
                                (entry.value /
                                            diseasedCount *
                                            100)
                                        .toStringAsFixed(1);

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style:
                                            const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),

                                      Text(
                                        '${entry.value} ($percentage%)',
                                        style:
                                            const TextStyle(
                                          fontSize: 14,
                                          color:
                                              Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      8,
                                    ),
                                    child:
                                        LinearProgressIndicator(
                                      value:
                                          entry.value /
                                              diseasedCount,

                                      minHeight: 8,

                                      backgroundColor:
                                          Colors.grey[300],

                                      valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                        _getColorForDisease(
                                          entry.key,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text(
                          'No disease data yet',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getColorForDisease(String disease) {
    switch (disease) {
      case 'Early Blight':
        return const Color(0xFFFFA726);

      case 'Late Blight':
        return const Color(0xFFD32F2F);

      case 'Bacterial Wilt':
        return const Color(0xFF6D4C41);

      default:
        return const Color(0xFF1B5E3A);
    }
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
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
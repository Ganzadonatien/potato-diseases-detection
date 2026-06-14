import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/services/report_storage.dart';

class FarmerReportsScreen extends StatefulWidget {
  const FarmerReportsScreen({super.key});

  @override
  State<FarmerReportsScreen> createState() => _FarmerReportsScreenState();
}

class _FarmerReportsScreenState extends State<FarmerReportsScreen> {
  final ReportStorage _storage = ReportStorage();
  List<ScanReport> _reports = [];
  Map<String, int> _dailyCounts = {};
  Map<String, Map<String, int>> _dailyCountsByDisease = {};
  Map<String, int> _diseaseCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    final reports = await _storage.loadReports();
    final now = DateTime.now().toUtc();
    // Build last 7 days keys
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dateKeys = days
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toList();

    final counts = <String, int>{};
    for (final k in dateKeys) counts[k] = 0;

    final diseaseCounts = <String, int>{};
    final dailyByDisease = <String, Map<String, int>>{};
    for (final r in reports) {
      final key = DateFormat('yyyy-MM-dd').format(r.createdAt.toUtc());
      if (counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      }
      final disease = r.diseaseName.isNotEmpty ? r.diseaseName : 'Unknown';
      diseaseCounts[disease] = (diseaseCounts[disease] ?? 0) + 1;

      // ensure disease map exists and initialized with date keys
      dailyByDisease.putIfAbsent(
          disease, () => Map.fromEntries(dateKeys.map((k) => MapEntry(k, 0))));
      if (dailyByDisease[disease]!.containsKey(key)) {
        dailyByDisease[disease]![key] = dailyByDisease[disease]![key]! + 1;
      }
    }

    setState(() {
      _reports = reports;
      _dailyCounts = counts;
      _diseaseCounts = diseaseCounts;
      _dailyCountsByDisease = dailyByDisease;
      _loading = false;
    });
  }

  List<FlSpot> _lineSpotsForDisease(String disease) {
    final keys = _dailyCounts.keys.toList();
    final spots = <FlSpot>[];
    for (var i = 0; i < keys.length; i++) {
      final v = _dailyCountsByDisease[disease]?[keys[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), v.toDouble()));
    }
    return spots;
  }

  Widget _buildChartCard() {
    final keys = _dailyCounts.keys.toList();

    // build one line per disease
    final List<LineChartBarData> lines = [];
    _dailyCountsByDisease.forEach((disease, _) {
      lines.add(LineChartBarData(
        spots: _lineSpotsForDisease(disease),
        isCurved: true,
        barWidth: 3,
        color: _colorForDisease(disease),
        dotData: FlDotData(show: true),
      ));
    });

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports (last 7 days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= keys.length) {
                            return const SizedBox.shrink();
                          }
                          final label = DateFormat('EEE').format(DateTime.parse(keys[idx]));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(label, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  minY: 0,
                  lineBarsData: lines,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: _dailyCountsByDisease.keys.map((d) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: _colorForDisease(d)),
                    const SizedBox(width: 6),
                    Text(d, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    if (_diseaseCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sections = _diseaseCounts.entries.map((entry) {
      final color = _colorForDisease(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
        radius: 55,
      );
    }).toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 32,
                        sectionsSpace: 4,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _diseaseCounts.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _colorForDisease(entry.key),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
    );
  }

  Color _colorForDisease(String disease) {
    switch (disease.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF66BB6A);
      case 'early-blight':
      case 'early blight':
        return const Color(0xFFF9A825);
      case 'late-blight':
      case 'late blight':
        return const Color(0xFFD32F2F);
      case 'bacterial-wilt':
      case 'bacterial wilt':
        return const Color(0xFF5E35B1);
      case 'pest':
        return const Color(0xFF0288D1);
      default:
        return const Color(0xFF78909C);
    }
  }

  Widget _buildRecentList() {
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No farmer reports yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan reports from farmers will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = _reports[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF66BB6A),
            child: Text(
              r.diseaseName.isNotEmpty ? r.diseaseName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(r.title),
          subtitle: Text(
            '${r.diseaseName} • ${DateFormat('yyyy-MM-dd HH:mm').format(r.createdAt.toLocal())}',
          ),
          trailing: Text(
            '${(r.confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Farmer Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'View scan reports from farmers in your area',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildChartCard(),
                        const SizedBox(height: 12),
                        _buildPieChartCard(),
                        const SizedBox(height: 12),
                        if (_reports.isNotEmpty)
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Recent Reports',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: _buildRecentList(),
                                ),
                              ],
                            ),
                          )
                        else
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: _buildRecentList(),
                            ),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.refresh),
        onPressed: _loadReports,
      ),
    );
  }
}

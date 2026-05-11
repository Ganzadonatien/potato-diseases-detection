import 'package:shared_preferences/shared_preferences.dart';
import 'package:irish_potato_app/models/scan_report.dart';

class ReportStorage {
  static const String _storageKey = 'scan_reports';

  Future<List<ScanReport>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];
    return rawList.map(ScanReport.fromRawJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveReport(ScanReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];
    rawList.insert(0, report.toRawJson());
    await prefs.setStringList(_storageKey, rawList);
  }

  Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

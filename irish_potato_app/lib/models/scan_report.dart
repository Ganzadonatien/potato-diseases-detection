import 'dart:convert';

class ScanReport {
  final String id;
  final String title;
  final String status;
  final String details;
  final String imageBase64;
  final DateTime createdAt;
  final String diseaseName;
  final double confidence;
  final String recommendation;

  ScanReport({
    required this.id,
    required this.title,
    required this.status,
    required this.details,
    required this.imageBase64,
    required this.createdAt,
    required this.diseaseName,
    required this.confidence,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'details': details,
      'imageBase64': imageBase64,
      'createdAt': createdAt.toIso8601String(),
      'diseaseName': diseaseName,
      'confidence': confidence,
      'recommendation': recommendation,
    };
  }

  factory ScanReport.fromJson(Map<String, dynamic> json) {
    return ScanReport(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      details: json['details'] as String,
      imageBase64: json['imageBase64'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
    );
  }

  String toRawJson() => json.encode(toJson());

  factory ScanReport.fromRawJson(String rawJson) =>
      ScanReport.fromJson(json.decode(rawJson) as Map<String, dynamic>);
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ScanReport {
  final String id;
  final String? userId;
  final String title;
  final String status;
  final String details;
  final String imageBase64; // For local storage
  final String? imageUrl; // For Firestore storage
  final DateTime createdAt;
  final String diseaseName;
  final double confidence;
  final String recommendation;
  final String? advice;
  final String? adviceBy;
  final DateTime? adviceCreatedAt;

  ScanReport({
    required this.id,
    this.userId,
    required this.title,
    required this.status,
    required this.details,
    required this.imageBase64,
    this.imageUrl,
    required this.createdAt,
    required this.diseaseName,
    required this.confidence,
    required this.recommendation,
    this.advice,
    this.adviceBy,
    this.adviceCreatedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'status': status,
      'details': details,
      'imageBase64': imageBase64,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'diseaseName': diseaseName,
      'confidence': confidence,
      'recommendation': recommendation,
    };

    if (userId != null) {
      map['userId'] = userId;
    }
    if (advice != null) {
      map['advice'] = advice;
    }
    if (adviceBy != null) {
      map['adviceBy'] = adviceBy;
    }
    if (adviceCreatedAt != null) {
      map['adviceCreatedAt'] = adviceCreatedAt!.toUtc().toIso8601String();
    }

    return map;
  }

  factory ScanReport.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime createdAt = DateTime.now().toUtc();

    if (createdAtRaw is String) {
      createdAt = DateTime.parse(createdAtRaw).toUtc();
    } else if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate().toUtc();
    }

    DateTime? adviceCreatedAt;
    if (json['adviceCreatedAt'] is String) {
      adviceCreatedAt = DateTime.parse(
        json['adviceCreatedAt'] as String,
      ).toUtc();
    } else if (json['adviceCreatedAt'] is Timestamp) {
      adviceCreatedAt = (json['adviceCreatedAt'] as Timestamp).toDate().toUtc();
    }

    return ScanReport(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      status: json['status'] as String,
      details: json['details'] as String,
      imageBase64: json['imageBase64'] as String? ?? '', // Optional for Firestore
      imageUrl: json['imageUrl'] as String?, // Get URL from Firestore
      createdAt: createdAt,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      advice: json['advice'] as String?,
      adviceBy: json['adviceBy'] as String?,
      adviceCreatedAt: adviceCreatedAt,
    );
  }

  String toRawJson() => json.encode(toJson());

  factory ScanReport.fromRawJson(String rawJson) =>
      ScanReport.fromJson(json.decode(rawJson) as Map<String, dynamic>);
}

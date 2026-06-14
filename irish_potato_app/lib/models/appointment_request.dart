class AppointmentRequest {
  final String id;
  final String farmerId;
  final String farmerName;
  final String agronomistId;
  final String agronomistName;
  final String reportId;
  final String diseaseName;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  AppointmentRequest({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.agronomistId,
    required this.agronomistName,
    required this.reportId,
    required this.diseaseName,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      agronomistId: json['agronomistId'] ?? '',
      agronomistName: json['agronomistName'] ?? '',
      reportId: json['reportId'] ?? '',
      diseaseName: json['diseaseName'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'agronomistId': agronomistId,
      'agronomistName': agronomistName,
      'reportId': reportId,
      'diseaseName': diseaseName,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:irish_potato_app/models/scan_report.dart';

class ReportImageWidget extends StatelessWidget {
  final ScanReport report;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ReportImageWidget({
    super.key,
    required this.report,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // If we have imageUrl (from Firestore), use network image
    if (report.imageUrl != null && report.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: report.imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        ),
      );
    }
    
    // Otherwise use base64 (from local storage)
    if (report.imageBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(report.imageBase64),
          width: width,
          height: height,
          fit: fit,
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        );
      }
    }
    
    // Fallback if no image available
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}

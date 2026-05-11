import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:irish_potato_app/models/scan_report.dart';
import 'package:irish_potato_app/services/report_storage.dart';
import 'dart:typed_data';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePhoto();
    });
  }

  Future<void> _capturePhoto() async {
    try {
      setState(() => _isLoading = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        // Simulate disease detection (replace with actual model)
        final detectionResult = _simulateDiseaseDetection();
        final report = ScanReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title:
              'Leaf Scan ${DateTime.now().toLocal().toString().split(' ').first}',
          status: detectionResult['status']!,
          details: detectionResult['details']!,
          imageBase64: base64Encode(bytes),
          createdAt: DateTime.now().toUtc(),
          diseaseName: detectionResult['diseaseName']!,
          confidence: detectionResult['confidence']!,
          recommendation: detectionResult['recommendation']!,
        );

        await ReportStorage().saveReport(report);

        setState(() {
          _imageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leaf captured successfully!')),
          );
          _navigateToResultScreen(report);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing photo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        // Simulate disease detection (replace with actual model)
        final detectionResult = _simulateDiseaseDetection();
        final report = ScanReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title:
              'Leaf Scan ${DateTime.now().toLocal().toString().split(' ').first}',
          status: detectionResult['status']!,
          details: detectionResult['details']!,
          imageBase64: base64Encode(bytes),
          createdAt: DateTime.now().toUtc(),
          diseaseName: detectionResult['diseaseName']!,
          confidence: detectionResult['confidence']!,
          recommendation: detectionResult['recommendation']!,
        );

        await ReportStorage().saveReport(report);

        setState(() {
          _imageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
          _navigateToResultScreen(report);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToResultScreen(ScanReport report) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanResultScreen(report: report)),
    );
  }

  Map<String, dynamic> _simulateDiseaseDetection() {
    // Simulate different disease detections for demo purposes
    final diseases = [
      {
        'status': 'Healthy',
        'details': 'No disease detected. Leaf appears healthy.',
        'diseaseName': 'None',
        'confidence': 0.95,
        'recommendation': 'Continue regular monitoring.',
      },
      {
        'status': 'Early Blight Detected',
        'details': 'Early blight symptoms identified on the leaf.',
        'diseaseName': 'Early Blight',
        'confidence': 0.87,
        'recommendation': 'Apply fungicide and remove affected leaves.',
      },
      {
        'status': 'Late Blight Detected',
        'details': 'Late blight symptoms present on the leaf.',
        'diseaseName': 'Late Blight',
        'confidence': 0.92,
        'recommendation':
            'Immediate treatment required. Isolate affected plants.',
      },
      {
        'status': 'Bacterial Wilt Detected',
        'details': 'Signs of bacterial wilt observed.',
        'diseaseName': 'Bacterial Wilt',
        'confidence': 0.78,
        'recommendation': 'Destroy infected plants and sterilize soil.',
      },
    ];

    // Randomly select a disease for simulation
    final randomIndex = DateTime.now().millisecondsSinceEpoch % diseases.length;
    return diseases[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A7A5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7A5A),
        centerTitle: true,
        title: const Text(
          'Capture',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Upload icon on the right
          IconButton(
            onPressed: _uploadFromGallery,
            icon: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Upload from gallery',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen image / camera preview
          Positioned.fill(
            child: _imageBytes != null
                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF5A7A5A),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'No leaf captured yet. Point the camera at the leaf and tap the button to scan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // Capture button at bottom center
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _capturePhoto,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoading ? Colors.grey : Colors.red,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Scan Leaf',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultScreen extends StatelessWidget {
  final ScanReport report;

  const ScanResultScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaf Analysis'),
        backgroundColor: const Color(0xFF5A7A5A),
      ),
      backgroundColor: const Color(0xFFEFEFEF),
      body: Column(
        children: [
          Expanded(
            child: Image.memory(
              base64Decode(report.imageBase64),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.status,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Disease Detected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.diseaseName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(report.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.recommendation,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Captured on ${report.createdAt.toLocal().toString().split('.').first}',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Next step',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use the captured image to run your classification model and show the specific disease or healthy state here.',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A7A5A),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Scan Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5A7A5A)),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text(
                          'Home',
                          style: TextStyle(color: Color(0xFF5A7A5A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

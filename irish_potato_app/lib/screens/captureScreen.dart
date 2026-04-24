import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
      });
    }
  }

  Future<void> _uploadFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
      });
    }
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
            child: _capturedImage != null
                ? Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/leaf_placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
          ),

          // Capture button at bottom center
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
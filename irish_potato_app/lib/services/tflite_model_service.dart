import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelPrediction {
  final String status;
  final String details;
  final String diseaseName;
  final double confidence;
  final String recommendation;

  const ModelPrediction({
    required this.status,
    required this.details,
    required this.diseaseName,
    required this.confidence,
    required this.recommendation,
  });
}

class TfliteModelService {
  TfliteModelService._();

  static final TfliteModelService instance = TfliteModelService._();

  static const String _modelAssetPath = 'assets/model_mobileNetV3_large.tflite';
  static const String _labelsAssetPath = 'assets/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [
    'Bacterial-wilt',
    'Early-blight',
    'Healthy',
    'Late-blight',
    'Pest',
  ];

  Future<void> ensureLoaded() async {
    if (_interpreter != null) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelAssetPath);
      _labels = await _loadLabels();
      final inputTensor = _interpreter!.getInputTensor(0);
      debugPrint(
        'TFLite model loaded: shape=${inputTensor.shape}, type=${inputTensor.type}',
      );
    } catch (e, st) {
      debugPrint('TFLite model load failed: $e\n$st');
      _interpreter = null;
    }
  }

  Future<ModelPrediction> predict(Uint8List imageBytes) async {
    await ensureLoaded();

    final interpreter = _interpreter;
    if (interpreter == null) {
      return _errorPrediction('Model not loaded');
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return _errorPrediction('Unable to decode image.');
    }

    final inputTensor = interpreter.getInputTensor(0);
    final shape = inputTensor.shape;
    if (shape.length < 4) {
      return _errorPrediction('Unexpected model input tensor shape.');
    }

    final height = shape[1];
    final width = shape[2];
    final channels = shape[3];
    if (height <= 0 || width <= 0 || channels <= 0) {
      return _errorPrediction('Unsupported model input dimensions.');
    }

    final isNhwc =
        shape[1] == height && shape[2] == width && shape[3] == channels;
    final isNchw =
        shape[1] == channels && shape[2] == height && shape[3] == width;
    if (!isNhwc && !isNchw) {
      return _errorPrediction('Unsupported model input layout.');
    }

    final outputTensor = interpreter.getOutputTensor(0);
    debugPrint('Loaded labels: $_labels');
    debugPrint(
      'TFLite model inputs: shape=${inputTensor.shape}, type=${inputTensor.type}, '
      'layout=${isNhwc ? 'NHWC' : 'NCHW'}',
    );
    debugPrint(
      'TFLite model outputs: shape=${outputTensor.shape}, type=${outputTensor.type}',
    );

    debugPrint('Resizing image to model input: $width x $height');
    final resized = _resizeImageForModel(decoded, width, height);
    debugPrint('Resized image size: ${resized.width} x ${resized.height}');
    final pixel = resized.getPixel(0, 0);
    debugPrint('Top-left pixel RGB: r=${pixel.r}, g=${pixel.g}, b=${pixel.b}');

    final input = _buildInputBuffer(
      resized,
      height,
      width,
      channels,
      inputTensor,
      isNhwc,
    );
    final output = _buildOutputBuffer(outputTensor);

    if (kDebugMode) {
      debugPrint(
        'Input type: ${inputTensor.type}, sample values: ${_sampleInputValues(resized, inputTensor, isNhwc)}',
      );
    }

    try {
      interpreter.run(input, output);
    } catch (e, st) {
      debugPrint('TFLite run failed: $e\n$st');
      return _errorPrediction('Model execution failed.');
    }

    var scores = _extractScores(output, outputTensor);
    debugPrint('Raw model output scores: $scores');
    if (scores.isEmpty) {
      return _errorPrediction('Model returned no scores.');
    }

    //scores = _softmax(scores);
    final bestIndex = _bestIndex(scores);
    final label = _labelForIndex(bestIndex);
    final confidence = scores[bestIndex].clamp(0.0, 1.0);
    debugPrint(
      'Best index: $bestIndex, label: $label, confidence: $confidence',
    );

    return _mapPrediction(label, confidence);
  }

  Future<List<String>> _loadLabels() async {
    try {
      final raw = await rootBundle.loadString(_labelsAssetPath);
      final cleaned = raw.trim();
      if (cleaned.isEmpty) return _labels;

      final lines = cleaned
          .split(RegExp(r'[\r\n]+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.length == 1 &&
          lines.first.startsWith('[') &&
          lines.first.endsWith(']')) {
        final content = lines.first.substring(1, lines.first.length - 1);
        final labels = content
            .split(',')
            .map((item) => _normalizeLabel(item))
            .where((label) => label.isNotEmpty)
            .toList();
        if (labels.isNotEmpty) {
          debugPrint('Loaded labels from asset: $labels');
          return labels;
        }
      }

      final labels = lines
          .map(_normalizeLabel)
          .where((label) => label.isNotEmpty)
          .toList();
      if (labels.isNotEmpty) {
        debugPrint('Loaded labels from asset: $labels');
        return labels;
      }
    } catch (_) {
      // fallback to embedded labels
    }
    return _labels;
  }

  Object _buildInputBuffer(
    img.Image resized,
    int height,
    int width,
    int channels,
    Tensor inputTensor,
    bool isNhwc,
  ) {
    final inputType = inputTensor.type;
    final quantParams = inputTensor.params;
    final scale = quantParams.scale;
    final zeroPoint = quantParams.zeroPoint;

    int quantizeValue(double value) {
      final quantized = (value / scale).round() + zeroPoint;
      if (inputType == TensorType.uint8) {
        return quantized.clamp(0, 255).toInt();
      }
      if (inputType == TensorType.int8) {
        return quantized.clamp(-128, 127).toInt();
      }
      return quantized.toInt();
    }

    dynamic convertPixel(num pixelValue) {
      if (inputType == TensorType.uint8 || inputType == TensorType.int8) {
        return quantizeValue(pixelValue.toDouble());
      }
      if (inputType == TensorType.int32) {
        return pixelValue;
      }
      return pixelValue ;
    }

    if (isNhwc) {
      return List.generate(
        1,
        (_) => List.generate(
          height,
          (y) => List.generate(width, (x) {
            final pixel = resized.getPixel(x, y);
            return [
              convertPixel(pixel.r),
              convertPixel(pixel.g),
              convertPixel(pixel.b),
            ];
          }),
        ),
      );
    }

    return List.generate(
      1,
      (_) => List.generate(
        channels,
        (c) => List.generate(
          height,
          (y) => List.generate(width, (x) {
            final pixel = resized.getPixel(x, y);
            final value = c == 0
                ? pixel.r
                : c == 1
                ? pixel.g
                : pixel.b;
            return convertPixel(value);
          }),
        ),
      ),
    );
  }

  img.Image _resizeImageForModel(img.Image decoded, int width, int height) {
    if (width == height) {
      return img.copyResizeCropSquare(decoded, size: width);
    }
    return img.copyResize(decoded, width: width, height: height);
  }

  Object _buildOutputBuffer(Tensor outputTensor) {
    final shape = outputTensor.shape;
    final outputType = outputTensor.type;
    final useInts =
        outputType == TensorType.uint8 ||
        outputType == TensorType.int8 ||
        outputType == TensorType.int32;

    if (shape.length == 2) {
      return useInts
          ? List.generate(shape[0], (_) => List<int>.filled(shape[1], 0))
          : List.generate(shape[0], (_) => List<double>.filled(shape[1], 0.0));
    }

    if (shape.isNotEmpty) {
      final total = shape.fold<int>(1, (product, value) => product * value);
      return useInts
          ? List<int>.filled(total, 0)
          : List<double>.filled(total, 0.0);
    }

    return useInts
        ? List<int>.filled(_labels.length, 0)
        : List<double>.filled(_labels.length, 0.0);
  }

  List<double> _extractScores(Object output, Tensor outputTensor) {
    final scores = <double>[];
    final outputType = outputTensor.type;
    final quantParams = outputTensor.params;
    final scale = quantParams.scale;
    final zeroPoint = quantParams.zeroPoint;
    final isQuantized =
        outputType == TensorType.uint8 ||
        outputType == TensorType.int8 ||
        outputType == TensorType.int32;

    void walk(dynamic value) {
      if (value is List) {
        for (final item in value) {
          walk(item);
        }
      } else if (value is num) {
        var score = value.toDouble();
        if (isQuantized) {
          score = (score - zeroPoint) * scale;
        }
        scores.add(score);
      }
    }

    walk(output);
    return scores;
  }

  List<double> _softmax(List<double> scores) {
    if (scores.isEmpty) return scores;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final expScores = scores.map((v) => math.exp(v - maxScore)).toList();
    final sumExp = expScores.fold<double>(0.0, (sum, v) => sum + v);
    if (sumExp == 0.0) {
      return List<double>.filled(scores.length, 0.0);
    }
    return expScores.map((v) => v / sumExp).toList();
  }

  List<dynamic> _sampleInputValues(
    img.Image resized,
    Tensor inputTensor,
    bool isNhwc,
  ) {
    final pixel = resized.getPixel(0, 0);
    if (inputTensor.type == TensorType.float32) {
      return isNhwc
          ? [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0]
          : [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
    }
    final quantParams = inputTensor.params;
    final scale = quantParams.scale;
    final zeroPoint = quantParams.zeroPoint;
    int quantizeValue(num value) =>
        ((value / scale).round() + zeroPoint).clamp(0, 255).toInt();
    return isNhwc
        ? [
            quantizeValue(pixel.r),
            quantizeValue(pixel.g),
            quantizeValue(pixel.b),
          ]
        : [
            quantizeValue(pixel.r),
            quantizeValue(pixel.g),
            quantizeValue(pixel.b),
          ];
  }

  int _bestIndex(List<double> scores) {
    var bestIndex = 0;
    var bestScore = scores.first;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  String _labelForIndex(int index) {
    if (index >= 0 && index < _labels.length) {
      return _labels[index];
    }
    return 'Unknown';
  }

  String _normalizeLabel(String label) {
    return label
        .replaceAll(RegExp(r'''^[\s\[\]'",]+|[\s\[\]'",]+$'''), '')
        .trim();
  }

  ModelPrediction _mapPrediction(String label, double confidence) {
    final normalized = label.toLowerCase();

    if (normalized.contains('healthy')) {
      return ModelPrediction(
        status: 'Healthy',
        details: 'No disease detected. Leaf appears healthy.',
        diseaseName: label,
        confidence: confidence,
        recommendation: 'Continue regular monitoring.',
      );
    }

    if (normalized.contains('early-blight') ||
        normalized.contains('early blight')) {
      return ModelPrediction(
        status: 'Early Blight Detected',
        details: 'Early blight symptoms identified on the leaf.',
        diseaseName: label,
        confidence: confidence,
        recommendation: 'Apply fungicide and remove affected leaves.',
      );
    }

    if (normalized.contains('late-blight') ||
        normalized.contains('late blight')) {
      return ModelPrediction(
        status: 'Late Blight Detected',
        details: 'Late blight symptoms present on the leaf.',
        diseaseName: label,
        confidence: confidence,
        recommendation:
            'Immediate treatment required. Isolate affected plants.',
      );
    }

    if (normalized.contains('bacterial-wilt') ||
        normalized.contains('bacterial wilt')) {
      return ModelPrediction(
        status: 'Bacterial Wilt Detected',
        details: 'Signs of bacterial wilt observed.',
        diseaseName: label,
        confidence: confidence,
        recommendation: 'Destroy infected plants and sterilize soil.',
      );
    }

    if (normalized.contains('pest')) {
      return ModelPrediction(
        status: 'Pest Detected',
        details: 'Possible pest damage detected on the leaf.',
        diseaseName: label,
        confidence: confidence,
        recommendation: 'Inspect the plant and apply pest control measures.',
      );
    }

    return ModelPrediction(
      status: '$label Detected',
      details: 'The model classified the leaf as $label.',
      diseaseName: label,
      confidence: confidence,
      recommendation: 'Follow agronomist guidance for this classification.',
    );
  }

  ModelPrediction _errorPrediction(String message) {
    return ModelPrediction(
      status: 'Unable to classify leaf',
      details: message,
      diseaseName: 'Unknown',
      confidence: 0.0,
      recommendation:
          'Please try again with a clear image or check the model connection.',
    );
  }
}

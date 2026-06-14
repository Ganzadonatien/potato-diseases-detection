import 'dart:io';

import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  final file = File('assets/model_mobileNetV3large.tflite').absolute;
  print('Model path: ${file.path}');
  final interpreter = await Interpreter.fromFile(file);
  print('Interpreter loaded');
  final input = interpreter.getInputTensor(0);
  final output = interpreter.getOutputTensor(0);
  print('Input shape: ${input.shape}');
  print('Input type: ${input.type}');
  print('Output shape: ${output.shape}');
  print('Output type: ${output.type}');
  interpreter.close();
}

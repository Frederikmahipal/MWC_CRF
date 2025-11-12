import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Service for classifying food images using TensorFlow Lite
class MLFoodClassifierService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static bool _isInitialized = false;
  static const String _modelPath = 'assets/models/food_model.tflite';
  static const String _labelsPath = 'assets/models/food_labels.txt';
  static int? _inputSize;

  /// Initialize the ML model
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load interpreter
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Get input tensor shape and type
      final inputTensor = _interpreter!.getInputTensors().first;
      _inputSize = inputTensor.shape[1]; // Assuming shape is [1, size, size, 3]
      print('Input tensor type: ${inputTensor.type}');
      print('Input tensor shape: ${inputTensor.shape}');

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      _isInitialized = true;
      print('MLinitialized successfully');

      return true;
    } catch (e) {
      print('Error initializing ML Food Classifier: $e');
      return false;
    }
  }

  /// Preprocess image for model input
  static dynamic _preprocessImage(img.Image image) {
    // Resize image to model input size
    final resized = img.copyResize(
      image,
      width: _inputSize!,
      height: _inputSize!,
    );

    // Convert to uint8 array [0, 255] with explicit typing
    final input = <List<List<List<int>>>>[];
    final batch = <List<List<int>>>[];

    for (int y = 0; y < _inputSize!; y++) {
      final row = <List<int>>[];
      for (int x = 0; x < _inputSize!; x++) {
        final pixel = resized.getPixel(x, y);
        final rgb = <int>[pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
        row.add(rgb);
      }
      batch.add(row);
    }
    input.add(batch);

    return input;
  }

  /// Classify food from image file
  static Future<String?> classifyFood(File imageFile) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      // Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        print('Failed to decode image');
        return null;
      }

      // Preprocess image
      final input = _preprocessImage(image);

      // Prepare output tensor - shape should match model output [1, numLabels]
      final outputTensor = _interpreter!.getOutputTensors().first;
      final outputShape = outputTensor.shape;
      print('Output shape: $outputShape');
      print('Output tensor type: ${outputTensor.type}');

      final output = List.generate(
        outputShape[0],
        (_) => List<int>.filled(outputShape[1], 0),
      );

      _interpreter!.run(input as Object, output);

      final predictions = output[0];
      int maxScore = predictions[0];
      int maxIndex = 0;
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      // Get label
      if (maxIndex < _labels.length) {
        final label = _labels[maxIndex].trim();
        // Convert uint8 confidence (0-255) to percentage (0-100)
        final confidence = (maxScore / 255.0) * 100.0;

        // Skip background class if present
        if (label.isNotEmpty && !label.toLowerCase().contains('background')) {
          print('Detected: $label (${confidence.toStringAsFixed(1)}%)');
          return label;
        }
      }

      return null;
    } catch (e) {
      print('Error classifying food: $e');
      return null;
    }
  }

  /// Dispose resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels.clear();
    _isInitialized = false;
  }
}

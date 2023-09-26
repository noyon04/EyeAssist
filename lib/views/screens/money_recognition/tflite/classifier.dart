import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:eye_assist/views/screens/money_recognition/tflite/money_recognition.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'stats.dart';

/// Classifier
class Classifier {
  /// Instance of Interpreter
  Interpreter? _interpreter;
  late InterpreterOptions _interpreterOptions;

  /// Labels file loaded as list
  List<String>? _labels;

  static const String MODEL_FILE_NAME = "detect_quant.tflite";
  static const String LABEL_FILE_NAME = "money_labelmap.txt";

  late List<int> _inputShape;
  late List<int> _outputShape;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;
  late var _probabilityProcessor;

  /// Input size of image (height = width = 300)
  static const int INPUT_SIZE = 320;

  /// Result score threshold
  static const double THRESHOLD = 0.5;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  /// Padding the image to transform into square
  int? padSize;
  final int _labelsLength = 4;

  /// Shapes of output tensors
  List<List<int>>? _outputShapes;

  /// Types of output tensors
  List<TfLiteType>? _outputTypes;

  /// Number of results to show
  static const int NUM_RESULTS = 10;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 1,
          );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {

        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      });
     
      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      _inputType = _interpreter!.getInputTensor(0).type;
      _outputType = _interpreter!.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(NormalizeOp(0, 255)).build();
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  TensorImage getProcessedImage() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    if(imageProcessor == null){
      imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(NormalizeOp(0, 1))
        .build();
    }
    return imageProcessor!.process(_inputImage);
  }

  // TensorImage getProcessedImage(imageLib.Image image) {
  //   // 1. Convert to TensorImage
  //   TensorImage tensorImage = TensorImage.fromImage(image);

  //   // 2. Resize and crop/pad
  //   ImageProcessor imageProcessor = ImageProcessorBuilder()
  //       .add(ResizeWithCropOrPadOp(INPUT_SIZE, INPUT_SIZE))
  //       .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
  //       .build();

  //   return imageProcessor.process(tensorImage);
  // }

  // /// Pre-process the image
  // TensorImage getProcessedImage(TensorImage inputImage) {
  //   padSize = max(inputImage.height, inputImage.width);
  //   if (imageProcessor == null) {
  //     imageProcessor = ImageProcessorBuilder()
  //         .add(ResizeWithCropOrPadOp(padSize!, padSize!))
  //         .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
  //         .build();
  //   }
  //   inputImage = imageProcessor!.process(inputImage);
  //   return inputImage;
  // }

  /// Runs object detection on the input image
  Map<String, dynamic> predict(imageLib.Image image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null!;
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    // TensorImage inputImage = TensorImage.fromImage(image);
    // TensorImage inputImage = TensorImage(TfLiteType.float32);
    // inputImage.loadImage(image);
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = getProcessedImage();
    // Pre-process TensorImage
    ///inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    //   // TensorBuffers for output tensors
    //  TensorBuffer outputLocations = TensorBufferFloat(_outputShapes![0]);
    //   TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![1]);
    //   TensorBuffer outputScores = TensorBufferFloat(_outputShapes![2]);
    //   TensorBuffer numLocations = TensorBufferFloat(_outputShapes![3]);
    // TensorBuffers for output tensors
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes![0]);
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes![1]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes![2]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![3]);
   

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [_inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter!.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 2;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<MoneyRecognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);
      print(score.toString()+ "score");
      // Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      if(labelIndex>3){
        labelIndex--;
      }
      var label = _labels!.elementAt(labelIndex);

      if (score > THRESHOLD) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor!
            .inverseTransformRect(locations[i], image.height, image.width);

        recognitions.add(
          MoneyRecognition(i, label, score, transformedRect),
        );
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    print("recognitions: "+ recognitions.toString());

    return {
      "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)
    };
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter!;

  /// Gets the loaded labels
  List<String> get labels => _labels!;
}

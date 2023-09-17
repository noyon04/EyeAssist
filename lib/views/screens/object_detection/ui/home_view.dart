import 'package:eye_assist/controller/stt/stt_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eye_assist/views/screens/object_detection/tflite/recognition.dart';
import 'package:eye_assist/views/screens/object_detection/tflite/stats.dart';
import 'package:eye_assist/views/screens/object_detection/ui/box_widget.dart';
import 'package:eye_assist/views/screens/object_detection/ui/camera_view_singleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../controller/camera/camera_controller.dart';
import '../../../../services/camera_service.dart';
import 'camera_view.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends ConsumerStatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition>? results;
  final CameraService _cameraService = CameraService();
  List<String> re = [];
  var mid = {};
  var left = {};
  var right = {};

  Future? _initializeControllerFuture;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      //_start();
    });
  }

  _start() async {
    var description = ref.watch(cameraProvider.notifier).cameraDescriptionFront;
    
    _initializeControllerFuture = _cameraService.startService(description!);
    await _initializeControllerFuture!;
     setState(() {
      //cameraInitializated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
        
          CameraView(resultsCallback, statsCallback),

          InkWell(
            onTap: () {
              getOutputs();
            },
            onDoubleTap: (){
              ref.watch(sttProvider.notifier).backHomeSpeech();
              Future.delayed(Duration(seconds: 2),(){
                 Navigator.pop(context);
              });
             
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ),

      
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results, CameraImage cameraImage) {
   
   // Future.delayed(Duration(milliseconds: 2000), () {
      ref.watch(sttProvider.notifier).objectDetectionProcess(results, cameraImage);
   // });
   
  }

  getOutputs() {
   
    ref.watch(sttProvider.notifier).speakDetectionResults();
    
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}

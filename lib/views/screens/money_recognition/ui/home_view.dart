import 'package:eye_assist/controller/camera/camera_controller.dart';
import 'package:eye_assist/controller/stt/stt_controller.dart';
import 'package:camera/camera.dart';
import 'package:eye_assist/services/camera_service.dart';
import 'package:eye_assist/views/screens/money_recognition/utils/image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eye_assist/views/screens/money_recognition/tflite/money_recognition.dart';
import 'package:eye_assist/views/screens/money_recognition/tflite/stats.dart';
import 'package:eye_assist/views/screens/money_recognition/ui/box_widget.dart';
import 'package:eye_assist/views/screens/money_recognition/ui/camera_view_singleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';


import '../../../styles/b_style.dart';
import 'camera_view.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeViewMoney extends ConsumerStatefulWidget {
  @override
  _HomeViewMoneyState createState() => _HomeViewMoneyState();
}

class _HomeViewMoneyState extends ConsumerState<HomeViewMoney> {
  /// Results to draw bounding boxes
  List<MoneyRecognition> results=[];
  final CameraService _cameraService = CameraService();
  List<String> re = [];
  var mid = {};
  var left = {};
  var right = {};

  Future? _initializeControllerFuture;
  CameraImage? img;
  

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
      //    boundingBoxes(results),

      Align(
                alignment: Alignment.bottomRight,
                child: GlassmorphicContainer(
                  width: 150,
                  height: 150,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 53, 49, 49).withOpacity(0.1),
                        Color.fromARGB(255, 110, 98, 98).withOpacity(0.05),
                      ],
                      stops: [
                        0.1,
                        1,
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFffffff).withOpacity(0.5),
                      Color((0xFFFFFFFF)).withOpacity(0.5),
                    ],
                  ),
                  child: Center(
                    child: Text(
                "Tap to hear the output\n Double tap to back",
                style: KTextStyle.bodyText1.copyWith(color: KColor.white),
                textAlign: TextAlign.center,
              )),
                  ),
                ),
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
  Widget boundingBoxes(List<MoneyRecognition> results) {
    if (results.isEmpty) {
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
  void resultsCallback(List<MoneyRecognition> results, CameraImage cameraImage) {
   
   // Future.delayed(Duration(milliseconds: 2000), () {
      ref.watch(sttProvider.notifier).moneyRecognitionProcess(results, cameraImage);
   // });
  //  setState(() {
  //   this.results = results;
  //  //  this.img = cameraImage;
  //  });
   
  }

  getOutputs() {
    //var convertedImg = ImageUtils.convertCameraImage(img!);
    //ImageUtils.saveImage2(convertedImg, 120);
    ref.watch(sttProvider.notifier).speakMoneyDetectionResults();
    
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

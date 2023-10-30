
import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:eye_assist/constants/output_string.dart';

import 'package:eye_assist/controller/stt/state/stt_state.dart';
import 'package:eye_assist/controller/tts/tts_controller.dart';
import 'package:eye_assist/views/screens/money_recognition/utils/image_utils.dart';
import 'package:image/image.dart' as imgLib;
import 'package:eye_assist/services/navigation_service.dart';

// import 'package:eye_assist/views/screens/object_detection/tflite/recognition.dart';
// import 'package:eye_assist/views/screens/object_detection/ui/camera_view_singleton.dart';
// import 'package:eye_assist/views/screens/object_detection/ui/home_view.dart';
import 'package:camera/camera.dart';

import 'package:eye_assist/views/screens/money_recognition/tflite/money_recognition.dart';
import 'package:eye_assist/views/screens/money_recognition/ui/home_view.dart';

import 'package:eye_assist/views/screens/object_detection/tflite/recognition.dart';
import 'package:eye_assist/views/screens/object_detection/ui/camera_view_singleton.dart';
import 'package:eye_assist/views/screens/object_detection/ui/home_view.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:weather/weather.dart';




final sttProvider = StateNotifierProvider<SttController, SttState>(
  (ref) => SttController(ref: ref),
);

class SttController extends StateNotifier<SttState> {
  final Ref? ref;
  SttController({this.ref}) : super(SttInitialState());

  SpeechToText speech = SpeechToText();
  String? speechResults;
  String? errorMessage;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  DateTime? dateTimeNow;
  bool? isLocationEnabled = false;
  double latitude = 0.0, longitude = 0.0;
  WeatherFactory wf = WeatherFactory("c84424caeb5cffc630069ff7f6db63fd");
  Battery? battery = Battery();
  String? finalDetectionResults = '';
  String? finalMoneyDetectionResults='';
  var scanResults;
  List? e11;
  var re = [];
  var left = {};
  var right = {};
  var mid = {};
  var finalAll={};
  var finalAllMoney={};

  ///location permission start///
  void locationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      speak("Please turn on your location service. You may need help.");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Locaion Error");
      }
    } else {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        speak("Please turn on your location service. You may need help.");
        isLocationEnabled = false;
      } else {
        isLocationEnabled = true;
      }
    }
  }

  Future requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    print("Storage Permission granted");
    //return true;
  } else if (status.isDenied) {
     print("Storage Permission not granted");
    // The permission was denied.
  //  return false;
  }

  // Handle other permission states if needed.
  //return false;
  
}

  ///location permission end///

  Future<void> initStt() async {
    await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
      debugLogging: true,
    );
    await requestStoragePermission();
    locationPermission();
    
  }

  Future startListening() async {
    state = SttLoadingState();
    try {
      await speech
          .listen(
              onResult: (result) {
                /// results of listening
                print("speech: " + result.recognizedWords);
                speechResults = '${result.recognizedWords}';
                toast(speechResults!.toString());
                state = SttSuccessState();
                //replaceUnwantedCharacter(speechResults!);
                 /// final result comparing with the command list ///////
                processResults(speechResults!);
              },
              listenFor: Duration(seconds: 10),
              pauseFor: Duration(seconds: 3),
              partialResults: false,
              localeId: "en-GB",
              onSoundLevelChange: (levelch) {
                minSoundLevel = min(minSoundLevel, level);
                maxSoundLevel = max(maxSoundLevel, level);

                level = levelch;
              },
              cancelOnError: true,
              listenMode: ListenMode.confirmation)
          .onError((error, stackTrace) {
        print(error);
        print(stackTrace);
        state = SttErrorState();
      });
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      state = SttErrorState();
    }
  }

  void errorListener(SpeechRecognitionError error) {
    // _logEvent(
    //     'Received error status: $error, listening: ${speech.isListening}');
    // setState(() {
    //   lastError = '${error.errorMsg} - ${error.permanent}';
    // });
  }

  void statusListener(String status) {
    // _logEvent(
    //     'Received listener status: $status, listening: ${speech.isListening}');
    // setState(() {
    //   lastStatus = '$status';
    // });
  }
  void stopListening() async {
    await speech.stop();
  }

  void speak(String text) {
    ref!.read(ttsProvider.notifier).speak(text);
  }


  getWeather() async {
    if (isLocationEnabled!) {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      Weather w = await wf.currentWeatherByLocation(latitude, longitude);
      var temperature = w.temperature!.celsius!.toStringAsFixed(1);
      toast("Weather now " + temperature + " Degree celcius");
      speak("Weather now " + temperature + " Degree celcius");
    } else {
      locationPermission();
    }
  }

  getBatteryLevel() async {
    var batt = await battery!.batteryLevel;
    speak("Your phone has " + batt.toString() + ", percent charge ");
  }

  backHomeSpeech(){
    speak(OutputString.backHome);
  }

  userLocation() async {
    if (isLocationEnabled!) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: "en-GB");
    
        toast("You are in " +
            placemarks[0].thoroughfare! +
            ", Postal code " +
            placemarks[0].postalCode! +
            "  " +
            placemarks[0].subAdministrativeArea! +
            " City");
        speak("You are in " +
            placemarks[0].thoroughfare! +
            ", Postal code " +
            placemarks[0].postalCode! +
            "  " +
            placemarks[0].subAdministrativeArea! +
            " City");
    //  }
    } else {
      locationPermission();
    }
  }

  getLocationOfImage(Rect location, String label, double size) {
    if (location.left < size * 0.40) {
      if (location.right < size * 0.40) {
        if (left.containsKey(label)) {
          left[label]++;
        } else {
          left[label] = 1;
        }
      } else {
        if (mid.containsKey(label)) {
          mid[label]++;
        } else {
          mid[label] = 1;
        }
        //re.add(label + "_M");
      }
    } else if (location.right > size * 0.40) {
      if (location.left > size * 0.40) {
        if (right.containsKey(label)) {
          right[label]++;
        } else {
          right[label] = 1;
        }
        //re.add(label + "_R");
      } else {
        if (mid.containsKey(label)) {
          mid[label]++;
        } else {
          mid[label] = 1;
        }
        //re.add(e.label + "_M");
      }
    }
  }

  void objectDetectionProcess(List<Recognition> results, CameraImage image,) {
    var size = CameraViewSingleton.inputImageSize!.width;
   
    finalAll={};
    left = {};
    right = {};
    mid = {};
   // results == null
        //? []
         
        //: //results.map((e)  async {
          for(var e in results){
            re.add("label: ${e.label}  score: ${e.score}");
             if (finalAll.containsKey(e.label)) {
              finalAll[e.label]++;
              } else {
                finalAll[e.label] = 1;
              }
            var location = e.location;

         
          };
    String finalResults = '';
    if(finalAll.isNotEmpty){
      finalResults+="Here ";
      finalAll.forEach((key, value) {
          finalResults += value.toString() + " " + key;
       });
    }
   
    finalDetectionResults = finalResults;
  }


  speakDetectionResults() {
    if (finalDetectionResults != '') {
      speak(finalDetectionResults!);
      toast(finalDetectionResults!);
    //  toast(re.toString());
    } else {
      speak('Sorry, i cant find anything');
       toast('Sorry, i cant find anything');
    }
  }


   void moneyRecognitionProcess(List<MoneyRecognition> results, CameraImage image,) {
   //var size = CameraViewSingleton.inputImageSize!.width;
   
    finalAllMoney={};
 
        //? []
         
        //: //results.map((e)  async {
          for(var e in results){
            
             if (finalAllMoney.containsKey(e.label)) {
              finalAllMoney[e.label]++;
              } else {
                finalAllMoney[e.label] = 1;
              }
            var location = e.location;

            
          };
    String finalResults = '';
    if(finalAllMoney.isNotEmpty){
      finalResults+="Here ";
      finalAllMoney.forEach((key, value) {
          finalResults += value.toString() + " " + key+ " pound";
       });
    }
    
    finalMoneyDetectionResults = finalResults;
  }


  

  speakMoneyDetectionResults() {
    print(finalMoneyDetectionResults);
    if (finalMoneyDetectionResults != '') {
      speak(finalMoneyDetectionResults!);
      toast(finalMoneyDetectionResults!);
    //  toast(re.toString());
    } else {
      speak('Sorry, i cant find anything');
       toast('Sorry, i cant find anything');
    }
  }
  





  void processResults(String userCommand) {
    print(userCommand);
    //toast(userCommand);
    /// final result comparing with the command list //////
    if (state is SttSuccessState) {
      /// time start ///
      if (userCommand.contains("time") 
       ) {
        dateTimeNow = DateTime.now();
        var time = DateFormat("hh:mm a").format(dateTimeNow!);
        speak("${OutputString.timeSpeech} $time");
      }

      /// time end ///

      /// date start ///
      else if (userCommand.contains(" date")
         || userCommand.trim()=="date"||userCommand.startsWith("date ")) {
        dateTimeNow = DateTime.now();
        var date = DateFormat("dd-MM-yyyy").format(dateTimeNow!);
        speak("${OutputString.dateSpeech} $date");
      }

      /// date end ///

      /// location start ///
      else if (userCommand.contains("location") ||
          userCommand.contains("where am i")) {
        userLocation();
      }

      /// location end ///

      /// Weather start ///
      else if (userCommand.contains("weather") ||
          userCommand.contains("temperature") 
   ) {
        getWeather();
      }

      /// Weather end ///

      /// Battery level start ///
      else if (userCommand.contains("battery charge") ||
          userCommand.contains("phone charge") ||
          userCommand.contains("battery percentage")) {
        getBatteryLevel();
      }

      /// Battery level end ///

      // Object Detection level start ///
      else if (userCommand.contains("object detection")) {
        NavigationService.navigateTo(
            CupertinoPageRoute(builder: (context) => HomeView()));
      }

      //Object Detection end ///
      
      // Money recognition level start ///
      else if (userCommand.contains("money")||userCommand.contains("currency")) {
        NavigationService.navigateTo(
            CupertinoPageRoute(builder: (context) => HomeViewMoney()));
      }

      //Money recognition end ///

      //// News update start //
      // else if (userCommand.contains("news")) {
      //   speak("Touch the screen to start listen News, And double tap to back to home screen. ");
      //   NavigationService.navigateTo(
      //       CupertinoPageRoute(builder: (context) => NewsScreen()));
      // }
      //// News update end //
      

      else{
        speak("Sorry, I don't understand.");
      }


    }
  }
}

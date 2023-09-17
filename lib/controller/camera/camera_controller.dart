
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraProvider = StateNotifierProvider<DeviceCameraController, Type>(
  (ref) => DeviceCameraController(ref: ref),
);

class DeviceCameraController extends StateNotifier<Type>{
   final Ref ref;
 
   DeviceCameraController({required this.ref}) : super(Type);
   // Services injection
 

  CameraDescription? cameraDescriptionFront;
  CameraDescription? cameraDescriptionBack;
  CameraLensDirection? directionFront;
  CameraLensDirection? directionNBack;
  

   Future initAllFaceRFunctions() async
   {
    List<CameraDescription> cameras = await availableCameras();
    

    /// takes the front camera
    cameraDescriptionFront = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
    directionFront = CameraLensDirection.front;
    /// takes the basck camera
    cameraDescriptionBack = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.back,
    );
    directionNBack = CameraLensDirection.back;

   } 
   

}
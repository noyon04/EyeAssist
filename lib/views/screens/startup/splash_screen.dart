
import 'package:eye_assist/views/screens/money_recognition/ui/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../constants/shared_preference_constant.dart';
import '../../../controller/camera/camera_controller.dart';
import '../../../controller/init/init_controller.dart';
import '../../../services/navigation_service.dart';
import '../../styles/b_style.dart';
import '../home/home_screen.dart';



class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
     
  }

  initData() async {
    bool isNewlyInstalled = getBoolAsync(NEWLY_INSTALLED, defaultValue: true);
    
   await ref.read(initProvider.notifier).initAllFunction();
    await ref.read(cameraProvider.notifier).initAllFaceRFunctions();
    
  }
  @override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: initData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        // Move to HomeScreen after initData is complete
        Future.microtask(() => Navigator.pushReplacement(context, FadeRoute(page: HomeScreen())));

        // You can return a widget here that you want to show after initialization
        // but before navigation if you want.
        return const SizedBox.shrink();
      }

      // Your splash screen content here
      return  Scaffold(
      backgroundColor: KColor.secondary,
      body: Center(
        child: Text(
          "EYE ASSIST",
          style: KTextStyle.headline2.copyWith(color: KColor.primary),
        ),
      ),
    ); // Example
    },
  );
}

  
}

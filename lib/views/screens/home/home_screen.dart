import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../constants/output_string.dart';
import '../../../controller/stt/state/stt_state.dart';
import '../../../controller/stt/stt_controller.dart';
import '../../../controller/tts/state/tts_state.dart';
import '../../../controller/tts/tts_controller.dart';
import '../../global_components/table_screen.dart';
import '../../styles/b_style.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      ref.read(ttsProvider.notifier).speak(OutputString.welcomeSpeech);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (builder, ref, _) {
      var sttResults = ref.watch(sttProvider.notifier).speechResults;
      var sttState = ref.watch(sttProvider);
      var ttsState = ref.watch(ttsProvider);

      return Scaffold(
          backgroundColor: KColor.secondary,
          body: Stack(
            children: [
              InkWell(
                onTap: () {
                  if (ttsState is TtsLoadingState ||
                      sttState is SttLoadingState) {
                    ref.read(ttsProvider.notifier).stopTts();
                    ref.read(sttProvider.notifier).stopListening();
                    ref.watch(sttProvider.notifier).startListening();
                  } else {
                    ref.watch(sttProvider.notifier).startListening();
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  // child: Image.asset(
                  //   AssetPath.backgroundPic,
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
              Align(
                  alignment: Alignment.center,
                child: TableScreen()),
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
                      "Click Anywhere to \nStart Listening",
                      style: KTextStyle.bodyText2.copyWith(
                        color: KColor.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ));
    });
  }
}



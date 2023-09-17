
import 'package:eye_assist/controller/tts/state/tts_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final ttsProvider = StateNotifierProvider<TtsController, TtsState>(
  (ref) => TtsController(ref: ref),
);

class TtsController extends StateNotifier<TtsState> {
  final Ref? ref;
  TtsController({this.ref}) : super(TtsInitialState());

  FlutterTts? flutterTts;

  Future initTts() async {
    flutterTts = FlutterTts();

    ///
    await flutterTts?.awaitSpeakCompletion(true);

    ///only if device is android
    var engine = await flutterTts?.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }

    ///initializing the language and all things (start)///
    await flutterTts?.setLanguage("en-GB");
    await flutterTts?.setVolume(1.0);
    await flutterTts?.setSpeechRate(0.6);
    await flutterTts?.setPitch(0.8);

    print("success");

    ///initializing the language and all things (end)///
  }

  Future stopTts ()async{
    ///stop text to speech
    await flutterTts!.stop();
    
  }


  Future speak(String text) async {
    state= TtsLoadingState();
    
    try{
      if (flutterTts != null && text.isNotEmpty) {
        /// start text to speech
      await flutterTts?.setLanguage("en-GB");
      await flutterTts?.setSpeechRate(0.5);
      await flutterTts?.setPitch(0.8);
      await flutterTts?.speak(text);
      state=TtsSuccessState();
    }else{
      state=TtsErrorState();
    }

    }catch(error, stackTrace){
      print(error);
      print(stackTrace);
      state=TtsErrorState();
    }
    
  }
}

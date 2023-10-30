

import 'package:eye_assist/controller/stt/stt_controller.dart';
import 'package:eye_assist/controller/tts/tts_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final initProvider = StateNotifierProvider<InitController, Type>(
  (ref) => InitController(ref: ref),
);

class InitController extends StateNotifier<Type>{
   final Ref ref;
 
   InitController({required this.ref}) : super(Type);

   Future initAllFunction() async
   {
     try{
      await ref.read(ttsProvider.notifier).initTts();
    await  ref.read(sttProvider.notifier).initStt();
    
     }catch(error,stackTrace){
       print(error);
      print(stackTrace);
     }
   } 

}
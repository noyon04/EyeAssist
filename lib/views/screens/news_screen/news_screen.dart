import 'package:eye_assist/controller/news/news_controller.dart';
import 'package:eye_assist/controller/news/state/news_state.dart';
import 'package:eye_assist/controller/tts/state/tts_state.dart';
import 'package:eye_assist/views/styles/b_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller/stt/stt_controller.dart';
import '../../../controller/tts/tts_controller.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  int currentNewsNumber = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (builder, ref, _) {
      final newsState = ref.watch(newsProvider);
      final news = ref.watch(newsProvider.notifier).news;
      var ttsState = ref.watch(ttsProvider);

      speakNews(int number) {
        ref.read(ttsProvider.notifier).speak("Title is " +
            news!.results[number].title +
            ". And the full news is ." +
            news.results[number].content);
      }

      return Scaffold(
        backgroundColor: KColor.secondary,
        body: InkWell(
          onTap: () {
            ref.read(ttsProvider.notifier).flutterTts!.stop();
            if (newsState == NewsErrorState) {
              ref
                  .read(ttsProvider.notifier)
                  .speak("Sorry for this inconvenience.");
            }

            if (newsState == NewsInitialState ||
                newsState == NewsLoadingState) {
              ref.read(ttsProvider.notifier).speak("Wait for a second Please.");
            } else if (currentNewsNumber == 10) {
              ref.read(newsProvider.notifier).fetchNextPage();
              ref
                  .read(ttsProvider.notifier)
                  .speak("Wait for a second Please. And tap again.");
              currentNewsNumber = 0;
            } else {
              speakNews(currentNewsNumber);
              currentNewsNumber++;
            }
          },
          onDoubleTap: () {
            ref.read(ttsProvider.notifier).flutterTts!.stop();
            ref.watch(sttProvider.notifier).backHomeSpeech();
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "NEWS",
                style: KTextStyle.headline2.copyWith(color: KColor.primary),
              ),
            ),
          ),
        ),
      );
    });
  }
}

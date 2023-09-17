abstract class TtsState{
  const TtsState();
}

class TtsInitialState extends TtsState{
  const TtsInitialState();
}
class TtsLoadingState extends TtsState{
  const TtsLoadingState();
}
class TtsSuccessState extends TtsState{
  const TtsSuccessState();
}
class TtsErrorState extends TtsState{
  const TtsErrorState();
}
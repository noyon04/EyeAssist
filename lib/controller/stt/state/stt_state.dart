abstract class SttState{
  const SttState();
}
class SttInitialState extends SttState{
  const SttInitialState();
}
class SttLoadingState extends SttState{
  const SttLoadingState();
}
class SttSuccessState extends SttState{
  const SttSuccessState();
}
class SttErrorState extends SttState{
  const SttErrorState();
}
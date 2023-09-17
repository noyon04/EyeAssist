abstract class NewsState{
  const NewsState();
}
class NewsInitialState extends NewsState{
  const NewsInitialState();
}
class NewsLoadingState extends NewsState{
  const NewsLoadingState();
}
class NewsSuccessState extends NewsState{
  const NewsSuccessState();
}
class NewsErrorState extends NewsState{
  const NewsErrorState();
}
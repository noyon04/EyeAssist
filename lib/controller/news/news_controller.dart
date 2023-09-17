import 'package:eye_assist/controller/news/state/news_state.dart';
import 'package:eye_assist/models/news_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final newsProvider = StateNotifierProvider<NewsController, NewsState>(
    (ref) => NewsController(ref: ref));

class NewsController extends StateNotifier<NewsState> {
  final Ref? ref;
  NewsController({this.ref}) : super(NewsInitialState());

  News? news;
  final String _baseUrl = 'https://newsdata.io/api/1/news';
  final String _apiKey = 'pub_294218486e776694925cdb39976f640b4698b';

  String _nextPage = ''; // to store the nextPage value from the response


  // Fetching the news
  Future fetchNews({String? page}) async {
    state= NewsLoadingState();
    final url = Uri.parse('$_baseUrl?country=gb&apikey=$_apiKey&language=en${page != null ? '&page=$page' : ''}');

    final response = await http.get(url);
 
    if (response.statusCode == 200) {
       news = newsFromJson(response.body);
      _nextPage = news!.nextPage; // store the nextPage value for future calls
      state= NewsSuccessState();
     
    } else {
      state = NewsErrorState();
      throw Exception('Failed to load news');
      
    }
  }

  // Fetching the next page
  Future fetchNextPage() async {
    if (_nextPage.isEmpty) {
      throw Exception('No next page available');
    }
    fetchNews(page: _nextPage);
  }
}

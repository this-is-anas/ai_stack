import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class NewsService {
  static const String _apiKey = 'YOUR-API-KEY';
  static const String _apiUrl =
      'https://newsapi.org/v2/top-headlines?category=technology&pageSize=20';

  Future<List<Article>> getTechNews() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_apiUrl&apiKey=$_apiKey'),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      print('News API request timed out');
      return [];
    } catch (e) {
      print('News API Error: $e');
      return [];
    }
  }

  List<Article> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return (jsonData['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
    }

    print('News API Error: ${response.statusCode} - ${response.body}');
    return [];
  }
}

class Article {
  final String title;
  final String description;
  final String url;
  final DateTime publishedAt;
  final String source;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.publishedAt,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt']),
      source: json['source']['name'] ?? 'Unknown source',
    );
  }
}

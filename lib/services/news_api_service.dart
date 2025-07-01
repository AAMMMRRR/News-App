import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  static const String _apiKey = '139854a87fcb4732aa47e4a740163f52';
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<Article>> fetchTopHeadlines({
    String country = 'us',
    String? category,
  }) async {
    String urlStr = '$_baseUrl?country=$country&apiKey=$_apiKey';
    if (category != null && category != 'general') {
      urlStr += '&category=$category';
    }

    final url = Uri.parse(urlStr);

    try {
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final List articlesJson = data['articles'];
          return articlesJson.map((json) => Article.fromJson(json)).toList();
        } else {
          throw Exception('API error: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load news: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Check your internet connection');
      } else if (e is TimeoutException) {
        throw Exception('Request timed out: Please try again later');
      } else {
        throw Exception('Error fetching news: $e');
      }
    }
  }
}

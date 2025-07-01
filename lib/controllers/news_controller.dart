import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';

class NewsController {
  final NewsApiService _newsApiService = NewsApiService();
  bool _isCancelled = false;

  List<Article> articles = [];
  bool isLoading = false;
  String? lastError;

  Future<void> loadArticles({String country = 'us', String? category}) async {
    const cacheDuration = Duration(hours: 1);
    final cacheKey = 'cached_articles_${category ?? "general"}';
    final timestampKey = 'cached_timestamp_${category ?? "general"}';

    try {
      isLoading = true;
      lastError = null;
      _isCancelled = false;

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final cachedTimestamp = prefs.getInt(timestampKey);

      final now = DateTime.now().millisecondsSinceEpoch;
      final isCacheValid =
          cachedTimestamp != null &&
          (now - cachedTimestamp) < cacheDuration.inMilliseconds;

      if (cachedData != null && isCacheValid) {
        final List jsonList = json.decode(cachedData);
        articles = jsonList.map((e) => Article.fromJson(e)).toList();
      } else {
        final fetched = await _newsApiService.fetchTopHeadlines(
          country: country,
          category: category,
        );

        if (_isCancelled) {
          return;
        }

        articles = fetched;

        await prefs.setString(
          cacheKey,
          json.encode(articles.map((e) => e.toJson()).toList()),
        );
        await prefs.setInt(timestampKey, now);
      }
    } catch (e) {
      if (_isCancelled) {
        return;
      }
      lastError = e.toString();
    } finally {
      if (!_isCancelled) {
        isLoading = false;
      }
    }
  }

  void cancel() {
    _isCancelled = true;
  }

  Future<void> clearCache({String? category}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_articles_${category ?? "general"}';
    final timestampKey = 'cached_timestamp_${category ?? "general"}';
    await prefs.remove(cacheKey);
    await prefs.remove(timestampKey);
  }
}

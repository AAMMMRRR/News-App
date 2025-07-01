import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../controllers/news_controller.dart';
import '../widgets/article_card.dart';
import '../widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsController _newsController = NewsController();
  final List<String> categories = [
    'general',
    'business',
    'sports',
    'technology',
    'health',
    'science',
    'entertainment',
  ];

  String selectedCategory = 'general';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles({String? category}) async {
    if (!mounted) return;
    setState(() {
      _newsController.isLoading = true;
    });

    await _newsController.loadArticles(
      country: 'us',
      category: category ?? selectedCategory,
    );

    if (mounted) {
      setState(() {
        if (_newsController.lastError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_newsController.lastError!)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true, // Prevent back navigation
      child: Scaffold(
        key: const Key('HomeScreen'),
        appBar: AppBar(
          title: const Text("Latest News"),
          backgroundColor: Colors.black,
          actions: [
            Row(
              children: [
                Text(
                  "Logout",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  iconSize: 25,
                  tooltip: 'Logout',
                  onPressed: () async {
                    try {
                      await _newsController.clearCache();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error signing out: $e")),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  bool isSelected = selectedCategory == category;

                  return GestureDetector(
                    onTap: () async {
                      if (!mounted) return;
                      setState(() {
                        selectedCategory = category;
                        _newsController.isLoading = true;
                      });
                      await _loadArticles(category: category);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child:
                  _newsController.isLoading
                      ? const Loading()
                      : _newsController.lastError != null &&
                          _newsController.articles.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_newsController.lastError!),
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      _loadArticles(category: selectedCategory),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadArticles,
                        child: ListView.builder(
                          itemCount: _newsController.articles.length,
                          itemBuilder: (context, index) {
                            Article article = _newsController.articles[index];
                            return ArticleCard(article: article);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newsController.cancel();
    super.dispose();
  }
}

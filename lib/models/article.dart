class Article {
  final String? title;
  final String? description;
  final String? urlToImage;
  final String? url;
  final String? content;
  final String? publishedAt;

  Article({
    this.title,
    this.description,
    this.urlToImage,
    this.url,
    this.content,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'],
      content: json['content'],
      publishedAt: json['publishedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'url': url,
      'content': content,
      'publishedAt': publishedAt,
    };
  }
}

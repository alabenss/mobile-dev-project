// lib/database/repo/articles_repo.dart
import '../../config/api_config.dart';
import '../../models/article_preview.dart';
import '../../services/api_service.dart';

class ArticleFull {
  final String slug;
  final String title;
  final String? summary;
  final String? heroImageUrl;
  final List<dynamic> content;

  const ArticleFull({
    required this.slug,
    required this.title,
    required this.content,
    this.summary,
    this.heroImageUrl,
  });

  factory ArticleFull.fromJson(Map<String, dynamic> json) {
    return ArticleFull(
      slug: (json['slug'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: json['summary']?.toString(),
      heroImageUrl: json['hero_image_url']?.toString(),
      content: (json['content'] ?? []) as List<dynamic>,
    );
  }
}

class ArticlesRepo {
  final ApiService _api = ApiService.instance;

  Future<List<ArticlePreview>> getAll({required String lang}) async {
    final res = await _api.get(
      ApiConfig.ARTICLES_GET_ALL,
      params: {'lang': lang},
    );

    if (res['success'] == true) {
      final list = (res['articles'] as List).cast<Map<String, dynamic>>();
      return list.map(ArticlePreview.fromJson).toList();
    }
    return [];
  }

  Future<ArticleFull> getBySlug({required String slug, required String lang}) async {
    final res = await _api.get(
      ApiConfig.ARTICLES_GET,
      params: {'slug': slug, 'lang': lang},
    );

    if (res['success'] == true && res['article'] != null) {
      return ArticleFull.fromJson(res['article'] as Map<String, dynamic>);
    }

    throw Exception(res['error'] ?? 'Failed to load article');
  }
}

// lib/models/article_preview.dart
class ArticlePreview {
  final String slug;
  final String title;
  final String? summary;
  final String? heroImageUrl;

  const ArticlePreview({
    required this.slug,
    required this.title,
    this.summary,
    this.heroImageUrl,
  });

  factory ArticlePreview.fromJson(Map<String, dynamic> json) {
  final rawUrl = json['hero_image_url']?.toString();

  return ArticlePreview(
    slug: (json['slug'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    summary: json['summary']?.toString(),
    heroImageUrl: rawUrl?.trim(),
  );
}

}

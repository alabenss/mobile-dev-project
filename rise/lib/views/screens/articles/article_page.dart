import 'package:flutter/material.dart';
import '../../../database/repo/articles_repo.dart';
import '../../themes/style_simple/colors.dart';

class ArticlePage extends StatefulWidget {
  final String slug;
  final String lang;

  const ArticlePage({
    super.key,
    required this.slug,
    required this.lang,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final ArticlesRepo _repo = ArticlesRepo();
  ArticleFull? _article;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await _repo.getBySlug(slug: widget.slug, lang: widget.lang);
      setState(() {
        _article = a;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }

    final a = _article!;
    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (a.heroImageUrl != null && a.heroImageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
  a.heroImageUrl!,
  height: 180,
  width: double.infinity,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  },
  errorBuilder: (context, error, stack) {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text("Image failed to load"),
    );
  },
)

            ),
            const SizedBox(height: 14),
          ],
          ...a.content.map(_blockWidget),
        ],
      ),
    );
  }

  Widget _blockWidget(dynamic block) {
    final m = block as Map<String, dynamic>;
    final type = m['type'];

    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            (m['text'] ?? '').toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        );

      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            (m['text'] ?? '').toString(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
        );

      case 'bullets':
        final items = (m['items'] ?? []) as List;
        return Column(
          children: items.map((t) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
                  Expanded(
                    child: Text(
                      '$t',
                      style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'quote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            (m['text'] ?? '').toString(),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
        );

      case 'footer':
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            (m['text'] ?? '').toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

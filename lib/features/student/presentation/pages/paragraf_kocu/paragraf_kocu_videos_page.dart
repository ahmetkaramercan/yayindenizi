import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../data/repositories/book_repository.dart';

final _bookVideosProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, bookId) async {
    final repo = sl<BookRepository>();
    return repo.getBookOutcomeVideos(bookId);
  },
);

class ParagrafKocuVideosPage extends ConsumerWidget {
  final String bookId;
  final String bookTitle;

  const ParagrafKocuVideosPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    return uri.queryParameters['v'] ?? '';
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(_bookVideosProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Videolar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: videosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Videolar yüklenemedi',
            style: AppTextStyles.body1.copyWith(color: AppColors.error),
          ),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Text(
                'Video bulunamadı',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            children: [
              Row(
                children: [
                  const Icon(Icons.play_circle_outline,
                      color: AppColors.error, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    bookTitle,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${videos.length} konu videosu',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              ...videos.map((v) {
                final videoUrl = v['videoUrl'] as String;
                final name = v['name'] as String;
                final category = v['category'] as String? ?? '';
                final videoId = _extractVideoId(videoUrl);
                final thumbnailUrl =
                    'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.paddingM),
                  child: InkWell(
                    onTap: () => _openVideo(videoUrl),
                    borderRadius: BorderRadius.circular(12),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  thumbnailUrl,
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 120,
                                    height: 80,
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    child: const Icon(Icons.play_circle_outline,
                                        color: AppColors.error, size: 36),
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 80,
                                  color: Colors.black26,
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (category.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        category,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

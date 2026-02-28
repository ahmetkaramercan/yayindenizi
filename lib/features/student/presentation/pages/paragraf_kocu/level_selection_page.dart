import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/book.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../data/repositories/book_repository.dart';

int _extractTestNumber(String title) {
  final directMatch = RegExp(r'(?:Test|Deneme)\s*(\d+)', caseSensitive: false)
      .firstMatch(title);
  if (directMatch != null) {
    return int.parse(directMatch.group(1)!);
  }

  final fallbackMatch = RegExp(r'(\d+)').firstMatch(title);
  return fallbackMatch != null ? int.parse(fallbackMatch.group(1)!) : 0;
}

final _bookSectionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, bookId) async {
  final repo = sl<BookRepository>();
  return repo.getBookSections(bookId);
});

class LevelSelectionPage extends ConsumerWidget {
  final Book book;

  const LevelSelectionPage({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(_bookSectionsProvider(book.id));
    final isLevelBasedBook = book.category == BookCategory.paragraf;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: sectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Bölümler yüklenemedi', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(_bookSectionsProvider(book.id)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (sections) {
          if (sections.isEmpty) {
            return const Center(child: Text('Henüz bölüm eklenmemiş'));
          }

          sections.sort((a, b) => (a['orderIndex'] as int? ?? 0)
              .compareTo(b['orderIndex'] as int? ?? 0));
          final allTests = sections
              .expand((section) => (section['tests'] as List? ?? const []))
              .cast<Map<String, dynamic>>()
              .toList();
          allTests.sort((a, b) {
            final aNum = _extractTestNumber(a['title'] as String? ?? '');
            final bNum = _extractTestNumber(b['title'] as String? ?? '');
            return aNum.compareTo(bNum);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kitap Analizim butonu
                AppCard(
                  onTap: () {
                    context.push(
                      '/student/book-analysis',
                      extra: {'bookId': book.id, 'bookTitle': book.title},
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kitap Analizim',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bu kitaptaki kazanım analizinizi görüntüleyin',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingL),
                Text(
                  isLevelBasedBook ? 'Seviye Seçin' : 'Denemeler',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLevelBasedBook
                      ? '${sections.length} farklı zorluk seviyesinden birini seçerek test çözebilirsiniz'
                      : '${allTests.length} denemeden birini seçerek test çözebilirsiniz',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingL),
                if (isLevelBasedBook)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConstants.paddingM,
                      mainAxisSpacing: AppConstants.paddingM,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final testCount = section['_count']?['tests'] ??
                          (section['tests'] as List?)?.length ??
                          0;

                      return _SectionCard(
                        index: index,
                        title: section['title'] ?? 'Bölüm ${index + 1}',
                        testCount: testCount,
                        isLevelBasedBook: true,
                        onTap: () {
                          context.push(
                            '/student/section-tests',
                            extra: {
                              'sectionId': section['id'],
                              'sectionTitle':
                                  section['title'] ?? 'Bölüm ${index + 1}',
                              'bookTitle': book.title,
                              'bookId': book.id,
                              'isParagrafBook':
                                  book.category == BookCategory.paragraf,
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allTests.length,
                    itemBuilder: (context, index) {
                      final test = allTests[index];

                      return AppCard(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingM,
                        ),
                        onTap: () {
                          context.push(
                            '/student/paragraf-kocu/test',
                            extra: test['id'] as String,
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.h6.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Expanded(
                              child: Text(
                                test['title'] as String? ??
                                    'Deneme ${index + 1}',
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int index;
  final String title;
  final int testCount;
  final bool isLevelBasedBook;
  final VoidCallback onTap;

  const _SectionCard({
    required this.index,
    required this.title,
    required this.testCount,
    required this.isLevelBasedBook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLevelBasedBook ? _getLevelColor(index) : AppColors.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: isLevelBasedBook
                ? Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.h3.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(
                    Icons.menu_book_outlined,
                    color: color,
                    size: 28,
                  ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$testCount test',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int index) {
    if (index <= 1) return AppColors.success;
    if (index <= 3) return AppColors.info;
    if (index <= 5) return AppColors.warning;
    return AppColors.error;
  }
}

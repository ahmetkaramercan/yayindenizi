import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../data/repositories/book_repository.dart';

int _extractTestNumber(String title) {
  final match = RegExp(r'Test\s*(\d+)').firstMatch(title);
  return match != null ? int.parse(match.group(1)!) : 0;
}

final _sectionTestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, sectionId) async {
  final repo = sl<BookRepository>();
  return repo.getSectionTests(sectionId);
});

class SectionTestListPage extends ConsumerWidget {
  final String sectionId;
  final String sectionTitle;
  final String bookTitle;
  final String? bookId;
  final bool isParagrafBook;

  const SectionTestListPage({
    super.key,
    required this.sectionId,
    required this.sectionTitle,
    required this.bookTitle,
    this.bookId,
    this.isParagrafBook = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(_sectionTestsProvider(sectionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(sectionTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: testsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Testler yüklenemedi', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(_sectionTestsProvider(sectionId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (tests) {
          if (tests.isEmpty) {
            return const Center(child: Text('Bu bölümde henüz test yok'));
          }

          tests.sort((a, b) {
            final aNum = _extractTestNumber(a['title'] as String? ?? '');
            final bNum = _extractTestNumber(b['title'] as String? ?? '');
            return aNum.compareTo(bNum);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            itemCount: tests.length + 1 + (isParagrafBook ? 1 : 0),
            itemBuilder: (context, index) {
              // Seviye Analizim butonu (sadece Paragraf Koçu, test listesinin sonunda)
              if (isParagrafBook && index == tests.length + 1) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingM),
                  child: AppCard(
                    onTap: () {
                      context.push(
                        '/student/section-analysis',
                        extra: {
                          'sectionId': sectionId,
                          'sectionTitle': sectionTitle,
                          'bookTitle': bookTitle,
                        },
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
                                'Seviye Analizim',
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$sectionTitle kazanım analizi',
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
                );
              }
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bookTitle - $sectionTitle',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tests.length} Test',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final test = tests[index - 1];
              final questionCount = test['_count']?['questions'] ?? (test['questions'] as List?)?.length ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                    vertical: AppConstants.paddingS,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Center(
                      child: Text(
                        '${index}',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    test['title'] ?? 'Test $index',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: questionCount > 0
                      ? Text(
                          '$questionCount soru',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    context.push(
                      '/student/paragraf-kocu/test',
                      extra: test['id'] as String,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/topic_provider.dart';

class TopicTestListPage extends ConsumerWidget {
  final String topicId;

  const TopicTestListPage({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicState = ref.watch(topicProvider);
    final currentTopic = topicState.currentTopic;
    final tests = topicState.topicTests;

    if (topicState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konu Testleri'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentTopic == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konu Testleri'),
        ),
        body: const Center(
          child: Text('Konu bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTopic.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.push('/student/konu-kitaplari/topic-analysis', extra: topicId);
            },
            tooltip: 'Kazanım Analizi',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(topicProvider.notifier).loadTopicTests(topicId);
        },
        child: tests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bu konu için henüz test bulunmuyor',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Konu Bilgisi
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTopic.title,
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentTopic.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              currentTopic.description!,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    // Test Listesi
                    Text(
                      'Testler',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    ...tests.map((test) => AppCard(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingM,
                          ),
                          onTap: () {
                            context.push(
                              '/student/konu-kitaplari/test',
                              extra: test.id,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      test.title,
                                      style: AppTextStyles.h6.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${test.questions.length} Soru',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (test.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  test.description!,
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}



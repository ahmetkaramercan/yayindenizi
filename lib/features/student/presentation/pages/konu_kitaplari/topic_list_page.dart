import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/topic_provider.dart';

class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicState = ref.watch(topicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konu Kitapları'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(topicProvider.notifier).loadTopics();
        },
        child: topicState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : topicState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          topicState.error!,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : topicState.topics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz konu bulunmuyor',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Konular',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            ...topicState.topics.map((topic) => AppCard(
                                  margin: const EdgeInsets.only(
                                    bottom: AppConstants.paddingM,
                                  ),
                                  onTap: () {
                                    context.push(
                                      '/student/konu-kitaplari/topic',
                                      extra: topic.id,
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              topic.title,
                                              style: AppTextStyles.h6.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (topic.testCount != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${topic.testCount} Test',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (topic.description != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          topic.description!,
                                          style: AppTextStyles.body2.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      if (topic.learningOutcomes.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: topic.learningOutcomes
                                              .take(3)
                                              .map((outcome) => Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.info
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      outcome.name,
                                                      style: AppTextStyles.caption
                                                          .copyWith(
                                                        color: AppColors.info,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
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



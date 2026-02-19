import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../providers/mock_test_provider.dart';

class MockTestListPage extends ConsumerWidget {
  const MockTestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(mockTestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Kitapları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.push('/student/deneme-kitaplari/analysis');
            },
            tooltip: 'Genel Analiz',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(mockTestProvider.notifier).loadTests();
        },
        child: testState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : testState.error != null
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
                          testState.error!,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : testState.tests.isEmpty
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
                              'Henüz deneme testi bulunmuyor',
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
                            // Genel Analiz Butonu
                            AppButton(
                              text: 'Genel Analiz',
                              icon: Icons.analytics_outlined,
                              onPressed: () {
                                context.push('/student/deneme-kitaplari/analysis');
                              },
                              type: AppButtonType.secondary,
                              isFullWidth: true,
                            ),
                            const SizedBox(height: AppConstants.paddingL),
                            // Test Listesi
                            ...testState.tests.map((test) => AppCard(
                                  margin: const EdgeInsets.only(
                                    bottom: AppConstants.paddingM,
                                  ),
                                  onTap: () {
                                    context.push(
                                      '/student/deneme-kitaplari/test',
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              '${test.questions.length} Soru',
                                              style: AppTextStyles.caption
                                                  .copyWith(
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
                                      if (test.timeLimit != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${test.timeLimit!.inMinutes} dakika',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
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



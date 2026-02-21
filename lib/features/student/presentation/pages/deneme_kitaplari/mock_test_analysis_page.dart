import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/mock_test_analysis_provider.dart';

class MockTestAnalysisPage extends ConsumerWidget {
  const MockTestAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(mockTestAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel Analiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(mockTestAnalysisProvider.notifier).loadAnalysis();
        },
        child: analysisState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : analysisState.error != null
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
                          analysisState.error!,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : analysisState.analysis == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz analiz verisi yok',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Test çözdükçe analiz verileri burada görünecek',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final analysis = analysisState.analysis!;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Genel İstatistikler
                            AppCard(
                              child: Column(
                                children: [
                                  Text(
                                    'Genel İstatistikler',
                                    style: AppTextStyles.h5.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _GeneralStatItem(
                                        label: 'Toplam Test',
                                        value: '${analysis.totalTests}',
                                        icon: Icons.quiz_outlined,
                                      ),
                                      _GeneralStatItem(
                                        label: 'Ortalama Başarı',
                                        value:
                                            '${analysis.averageSuccessPercentage.toInt()}%',
                                        icon: Icons.trending_up,
                                        color: _getSuccessColor(
                                            analysis.averageSuccessPercentage),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _GeneralStatItem(
                                        label: 'Doğru',
                                        value: '${analysis.totalCorrectAnswers}',
                                        icon: Icons.check_circle_outline,
                                        color: AppColors.success,
                                      ),
                                      _GeneralStatItem(
                                        label: 'Yanlış',
                                        value: '${analysis.totalWrongAnswers}',
                                        icon: Icons.cancel_outlined,
                                        color: AppColors.error,
                                      ),
                                      _GeneralStatItem(
                                        label: 'Boş',
                                        value: '${analysis.totalEmptyAnswers}',
                                        icon: Icons.remove_circle_outline,
                                        color: AppColors.warning,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingL),
                            // Son Testler
                            Text(
                              'Son ${analysis.recentResults.length} Test',
                              style: AppTextStyles.h5.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            ...analysis.recentResults.map((result) => AppCard(
                                  margin: const EdgeInsets.only(
                                    bottom: AppConstants.paddingM,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              result.testTitle,
                                              style: AppTextStyles.h6.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getSuccessColor(
                                                      result.successPercentage)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              '${result.successPercentage.toInt()}%',
                                              style: AppTextStyles.body2
                                                  .copyWith(
                                                color: _getSuccessColor(
                                                    result.successPercentage),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _ResultStatItem(
                                            label: 'Doğru',
                                            value: '${result.correctAnswers}',
                                            color: AppColors.success,
                                          ),
                                          _ResultStatItem(
                                            label: 'Yanlış',
                                            value: '${result.wrongAnswers}',
                                            color: AppColors.error,
                                          ),
                                          _ResultStatItem(
                                            label: 'Boş',
                                            value: '${result.emptyAnswers}',
                                            color: AppColors.warning,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: AppConstants.paddingL),
                            // Kazanım Bazlı Analiz
                            if (analysis.learningOutcomeStats.isNotEmpty) ...[
                              Text(
                                'Kazanım Bazlı Analiz',
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingM),
                              ...analysis.learningOutcomeStats.values
                                  .map((stats) => AppCard(
                                        margin: const EdgeInsets.only(
                                          bottom: AppConstants.paddingM,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    stats.learningOutcome.name,
                                                    style: AppTextStyles.h6
                                                        .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getSuccessColor(
                                                            stats
                                                                .successPercentage)
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    '${stats.successPercentage.toInt()}%',
                                                    style: AppTextStyles.body2
                                                        .copyWith(
                                                      color: _getSuccessColor(
                                                          stats
                                                              .successPercentage),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            LinearProgressIndicator(
                                              value: stats.successPercentage /
                                                  100,
                                              backgroundColor: AppColors.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                _getSuccessColor(
                                                    stats.successPercentage),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                _ResultStatItem(
                                                  label: 'Toplam',
                                                  value:
                                                      '${stats.totalQuestions}',
                                                  color: AppColors.textSecondary,
                                                ),
                                                _ResultStatItem(
                                                  label: 'Doğru',
                                                  value:
                                                      '${stats.correctAnswers}',
                                                  color: AppColors.success,
                                                ),
                                                _ResultStatItem(
                                                  label: 'Yanlış',
                                                  value:
                                                      '${stats.wrongAnswers}',
                                                  color: AppColors.error,
                                                ),
                                                _ResultStatItem(
                                                  label: 'Boş',
                                                  value:
                                                      '${stats.emptyAnswers}',
                                                  color: AppColors.warning,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getSuccessColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.info;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _GeneralStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _GeneralStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color ?? AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ResultStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


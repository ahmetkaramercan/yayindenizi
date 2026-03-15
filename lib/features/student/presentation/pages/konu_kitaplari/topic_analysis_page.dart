import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/topic_provider.dart';
import '../../../domain/entities/topic_test_result.dart';

enum AnalysisSortOrder {
  mostWrong,
  mostCorrect,
  alphabetical,
}

extension AnalysisSortOrderLabel on AnalysisSortOrder {
  String get label {
    switch (this) {
      case AnalysisSortOrder.mostWrong:
        return 'En Çok Yanlış';
      case AnalysisSortOrder.mostCorrect:
        return 'En Çok Doğru';
      case AnalysisSortOrder.alphabetical:
        return 'Alfabetik';
    }
  }

  IconData get icon {
    switch (this) {
      case AnalysisSortOrder.mostWrong:
        return Icons.cancel_outlined;
      case AnalysisSortOrder.mostCorrect:
        return Icons.check_circle_outline;
      case AnalysisSortOrder.alphabetical:
        return Icons.sort_by_alpha;
    }
  }
}

class TopicAnalysisPage extends ConsumerStatefulWidget {
  final String topicId;

  const TopicAnalysisPage({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<TopicAnalysisPage> createState() => _TopicAnalysisPageState();
}

class _TopicAnalysisPageState extends ConsumerState<TopicAnalysisPage> {
  AnalysisSortOrder _sortOrder = AnalysisSortOrder.mostWrong;

  List<TopicLearningOutcomeStats> _sorted(
      List<TopicLearningOutcomeStats> list) {
    final sorted = List<TopicLearningOutcomeStats>.from(list);
    switch (_sortOrder) {
      case AnalysisSortOrder.mostWrong:
        sorted.sort((a, b) {
          final aRate =
              a.totalQuestions > 0 ? a.wrongAnswers / a.totalQuestions : 0.0;
          final bRate =
              b.totalQuestions > 0 ? b.wrongAnswers / b.totalQuestions : 0.0;
          return bRate.compareTo(aRate);
        });
        break;
      case AnalysisSortOrder.mostCorrect:
        sorted.sort((a, b) {
          final aRate =
              a.totalQuestions > 0 ? a.correctAnswers / a.totalQuestions : 0.0;
          final bRate =
              b.totalQuestions > 0 ? b.correctAnswers / b.totalQuestions : 0.0;
          return bRate.compareTo(aRate);
        });
        break;
      case AnalysisSortOrder.alphabetical:
        sorted.sort((a, b) => a.learningOutcome.name
            .toLowerCase()
            .compareTo(b.learningOutcome.name.toLowerCase()));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final topicState = ref.watch(topicProvider);
    final analysis = topicState.topicAnalysis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kazanım Analizi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(topicProvider.notifier).loadTopicAnalysis(widget.topicId);
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
                : analysis == null || analysis.isEmpty
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
                              'Bu konuda test çözdükçe kazanım analizi burada görünecek',
                              style: AppTextStyles.body2.copyWith(
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
                            if (topicState.currentTopic != null) ...[
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topicState.currentTopic!.title,
                                      style: AppTextStyles.h5.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (topicState.currentTopic!.description !=
                                        null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        topicState.currentTopic!.description!,
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingL),
                            ],
                            // Kazanım Analizi Başlığı + Sıralama
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kazanım Bazlı Analiz',
                                    style: AppTextStyles.h5.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _SortMenuButton(
                                  current: _sortOrder,
                                  onSelected: (order) =>
                                      setState(() => _sortOrder = order),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            // Kazanım Kartları
                            ..._sorted(analysis.values.toList()).map((stats) =>
                                AppCard(
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
                                              stats.learningOutcome.name,
                                              style: AppTextStyles.h6.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              // Tamamlanma yüzdesi
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.info
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '100%',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                    color: AppColors.info,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Başarı yüzdesi
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getPercentageColor(
                                                          stats
                                                              .successPercentage)
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  '${stats.successPercentage.toInt()}%',
                                                  style: AppTextStyles.body2
                                                      .copyWith(
                                                    color: _getPercentageColor(
                                                        stats
                                                            .successPercentage),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (stats.learningOutcome.description !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          stats.learningOutcome.description!,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      // Başarı Progress Bar
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Başarı',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                '${stats.correctAnswers}/${stats.totalQuestions}',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value:
                                                stats.successPercentage / 100,
                                            backgroundColor: AppColors.border,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              _getPercentageColor(
                                                  stats.successPercentage),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Detaylı İstatistikler
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _DetailStatItem(
                                            label: 'Toplam Soru',
                                            value: '${stats.totalQuestions}',
                                            icon: Icons.quiz_outlined,
                                          ),
                                          _DetailStatItem(
                                            label: 'Doğru',
                                            value: '${stats.correctAnswers}',
                                            icon: Icons.check_circle_outline,
                                            color: AppColors.success,
                                          ),
                                          _DetailStatItem(
                                            label: 'Yanlış',
                                            value: '${stats.wrongAnswers}',
                                            icon: Icons.cancel_outlined,
                                            color: AppColors.error,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: AppConstants.paddingL),
                            // Geri Dön Butonu
                            AppButton(
                              text: 'Konu Testlerine Dön',
                              icon: Icons.list,
                              onPressed: () {
                                context.pop();
                              },
                              type: AppButtonType.outline,
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.info;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _SortMenuButton extends StatelessWidget {
  final AnalysisSortOrder current;
  final ValueChanged<AnalysisSortOrder> onSelected;

  const _SortMenuButton({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AnalysisSortOrder>(
      onSelected: onSelected,
      tooltip: 'Sıralama',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      itemBuilder: (context) => AnalysisSortOrder.values
          .map(
            (order) => PopupMenuItem<AnalysisSortOrder>(
              value: order,
              child: Row(
                children: [
                  Icon(
                    order.icon,
                    size: 18,
                    color: current == order
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.label,
                    style: AppTextStyles.body2.copyWith(
                      color: current == order
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: current == order
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (current == order) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 16, color: AppColors.primary),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(current.icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              current.label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _DetailStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h6.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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

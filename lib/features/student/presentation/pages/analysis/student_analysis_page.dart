import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/student_analysis_provider.dart';
import '../../../domain/entities/student_analysis.dart';

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

class StudentAnalysisPage extends ConsumerStatefulWidget {
  const StudentAnalysisPage({super.key});

  @override
  ConsumerState<StudentAnalysisPage> createState() =>
      _StudentAnalysisPageState();
}

class _StudentAnalysisPageState extends ConsumerState<StudentAnalysisPage> {
  AnalysisSortOrder _sortOrder = AnalysisSortOrder.mostWrong;

  List<LearningOutcomeProgress> _sorted(List<LearningOutcomeProgress> list) {
    final sorted = List<LearningOutcomeProgress>.from(list);
    switch (_sortOrder) {
      case AnalysisSortOrder.mostWrong:
        sorted.sort((a, b) {
          final aRate = a.completedQuestions > 0
              ? a.incorrectAnswers / a.completedQuestions
              : 0.0;
          final bRate = b.completedQuestions > 0
              ? b.incorrectAnswers / b.completedQuestions
              : 0.0;
          return bRate.compareTo(aRate);
        });
        break;
      case AnalysisSortOrder.mostCorrect:
        sorted.sort((a, b) {
          final aRate = a.completedQuestions > 0
              ? a.correctAnswers / a.completedQuestions
              : 0.0;
          final bRate = b.completedQuestions > 0
              ? b.correctAnswers / b.completedQuestions
              : 0.0;
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
    final analysisState = ref.watch(studentAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizim'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(studentAnalysisProvider.notifier).loadAnalysis();
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
                          final progressList = _sorted(
                              analysis.learningOutcomeProgress.values.toList());

                          return SingleChildScrollView(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingM),
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
                                            label: 'Tamamlanan Test',
                                            value:
                                                '${analysis.totalTestsCompleted}',
                                            icon: Icons.quiz_outlined,
                                          ),
                                          _GeneralStatItem(
                                            label: 'Genel Başarı',
                                            value:
                                                '${analysis.overallSuccessPercentage.toInt()}%',
                                            icon: Icons.trending_up,
                                            color: _getSuccessColor(analysis
                                                .overallSuccessPercentage),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingL),
                                // Kazanım Bazlı Analiz başlığı + sıralama
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
                                ...progressList.map((progress) =>
                                    _LearningOutcomeCard(progress: progress)),
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

// ─── Sıralama Butonu ───────────────────────────────────────────────────────────

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

// ─── Widget'lar ────────────────────────────────────────────────────────────────

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

class _LearningOutcomeCard extends StatelessWidget {
  final LearningOutcomeProgress progress;

  const _LearningOutcomeCard({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  progress.learningOutcome.name,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${progress.completionPercentage.toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Başarı yüzdesi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSuccessColor(progress.successPercentage)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${progress.successPercentage.toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: _getSuccessColor(progress.successPercentage),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (progress.learningOutcome.description != null) ...[
            const SizedBox(height: 8),
            Text(
              progress.learningOutcome.description!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Tamamlanma Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tamamlanma',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${progress.completedQuestions}/${progress.totalQuestions}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.completionPercentage / 100,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Başarı Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Başarı',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${progress.correctAnswers}/${progress.completedQuestions}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.successPercentage / 100,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getSuccessColor(progress.successPercentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Detaylı İstatistikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DetailStatItem(
                label: 'Toplam Soru',
                value: '${progress.totalQuestions}',
                icon: Icons.quiz_outlined,
              ),
              _DetailStatItem(
                label: 'Doğru',
                value: '${progress.correctAnswers}',
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
              _DetailStatItem(
                label: 'Yanlış',
                value: '${progress.incorrectAnswers}',
                icon: Icons.cancel,
                color: AppColors.error,
              ),
            ],
          ),
        ],
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

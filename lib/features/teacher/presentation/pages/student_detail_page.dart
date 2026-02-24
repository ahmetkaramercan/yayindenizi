import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../../../student/domain/entities/test_history.dart';
import '../providers/teacher_student_detail_provider.dart';

class StudentDetailPage extends ConsumerWidget {
  final String studentId;

  const StudentDetailPage({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(teacherStudentDetailProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(detailState.student?.adSoyad ?? 'Öğrenci Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                _showDeleteDialog(context, ref, detailState.student),
            tooltip: 'Öğrenciyi Sil',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(teacherStudentDetailProvider(studentId).notifier).loadData();
        },
        child: detailState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : detailState.error != null
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
                          detailState.error!,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.error,
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
                        // Öğrenci Bilgileri
                        if (detailState.student != null) ...[
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppColors.primaryLight,
                                      child: Text(
                                        detailState.student!.adSoyad.isNotEmpty
                                            ? detailState.student!.adSoyad[0]
                                                .toUpperCase()
                                            : 'Ö',
                                        style: AppTextStyles.h4.copyWith(
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppConstants.paddingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detailState.student!.adSoyad,
                                            style: AppTextStyles.h5.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            detailState.student!.email,
                                            style: AppTextStyles.body2.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (detailState.student!.locationDisplay != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              detailState.student!.locationDisplay!,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                        ],
                        // Genel Başarı
                        if (detailState.analysis != null) ...[
                          AppCard(
                            child: Column(
                              children: [
                                Text(
                                  'Genel Başarı',
                                  style: AppTextStyles.h5.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: detailState.analysis!
                                            .overallSuccessPercentage /
                                        100,
                                    strokeWidth: 10,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getSuccessColor(detailState
                                          .analysis!.overallSuccessPercentage),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${detailState.analysis!.overallSuccessPercentage.toInt()}%',
                                  style: AppTextStyles.h3.copyWith(
                                    color: _getSuccessColor(detailState
                                        .analysis!.overallSuccessPercentage),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${detailState.analysis!.totalTestsCompleted} Test Çözüldü',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                        ],
                        // Kazanım Bazlı Analiz
                        if (detailState.analysis != null &&
                            detailState.analysis!.learningOutcomeProgress
                                .isNotEmpty) ...[
                          Text(
                            'Kazanım Bazlı Analiz',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          ...(detailState
                                  .analysis!.learningOutcomeProgress.values
                                  .toList()
                                ..sort((a, b) => b.completedQuestions
                                    .compareTo(a.completedQuestions)))
                              .map((progress) => _LearningOutcomeCard(
                                    progress: progress,
                                  )),
                          const SizedBox(height: AppConstants.paddingL),
                        ],
                        // Test Geçmişi
                        Text(
                          'Test Geçmişi',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        if (detailState.testHistory.isEmpty)
                          AppCard(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz test geçmişi yok',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...detailState.testHistory.map((history) => AppCard(
                                margin: const EdgeInsets.only(
                                  bottom: AppConstants.paddingM,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                history.testTitle,
                                                style:
                                                    AppTextStyles.h6.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getTestTypeColor(
                                                              history.testType)
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      history
                                                          .testTypeDisplayName,
                                                      style: AppTextStyles
                                                          .caption
                                                          .copyWith(
                                                        color:
                                                            _getTestTypeColor(
                                                                history
                                                                    .testType),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (history.level !=
                                                      null) ...[
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Seviye ${history.level}',
                                                      style: AppTextStyles
                                                          .caption
                                                          .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                  if (history.topicTitle !=
                                                      null) ...[
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      history.topicTitle!,
                                                      style: AppTextStyles
                                                          .caption
                                                          .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getSuccessColor(
                                                    history.successPercentage)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            '${history.successPercentage.toInt()}%',
                                            style: AppTextStyles.body2.copyWith(
                                              color: _getSuccessColor(
                                                  history.successPercentage),
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
                                        _HistoryStatItem(
                                          label: 'Doğru',
                                          value: '${history.correctAnswers}',
                                          color: AppColors.success,
                                        ),
                                        _HistoryStatItem(
                                          label: 'Yanlış',
                                          value: '${history.wrongAnswers}',
                                          color: AppColors.error,
                                        ),
                                        if (history.emptyAnswers != null)
                                          _HistoryStatItem(
                                            label: 'Boş',
                                            value: '${history.emptyAnswers}',
                                            color: AppColors.warning,
                                          ),
                                        _HistoryStatItem(
                                          label: 'Toplam',
                                          value: '${history.totalQuestions}',
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(history.completedAt),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Student? student) {
    if (student == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
            '${student.adSoyad} adlı öğrenciyi listeden çıkarmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Sil',
            onPressed: () {
              ref
                  .read(teacherStudentDetailProvider(studentId).notifier)
                  .removeStudent(student.id ?? '');
              Navigator.of(context).pop();
              context.pop();
            },
            type: AppButtonType.danger,
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

  Color _getTestTypeColor(TestType type) {
    switch (type) {
      case TestType.paragrafKocu:
        return AppColors.primary;
      case TestType.deneme:
        return AppColors.accent;
      case TestType.konu:
        return AppColors.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DetailStatItem(
                label: 'Toplam',
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

class _HistoryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HistoryStatItem({
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

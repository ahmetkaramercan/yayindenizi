import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../providers/teacher_student_analysis_provider.dart';
import '../providers/teacher_dashboard_provider.dart';

class TeacherStudentAnalysisPage extends ConsumerStatefulWidget {
  const TeacherStudentAnalysisPage({super.key});

  @override
  ConsumerState<TeacherStudentAnalysisPage> createState() =>
      _TeacherStudentAnalysisPageState();
}

class _TeacherStudentAnalysisPageState
    extends ConsumerState<TeacherStudentAnalysisPage> {
  final _searchController = TextEditingController();
  String? _selectedStudentId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(teacherDashboardProvider);
    final analysisState = ref.watch(teacherStudentAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Analizi'),
      ),
      body: Column(
        children: [
          // Öğrenci Seçimi
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Öğrenci Ara',
                  hint: 'Öğrenci adı veya email ile ara',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    // TODO: Öğrenci arama
                  },
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Öğrenci Listesi
                if (dashboardState.students.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dashboardState.students.length,
                      itemBuilder: (context, index) {
                        final student = dashboardState.students[index];
                        final isSelected = _selectedStudentId == student.id;

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: AppConstants.paddingS,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedStudentId = student.id;
                              });
                              ref
                                  .read(teacherStudentAnalysisProvider.notifier)
                                  .loadStudentAnalysis(student.id ?? '');
                            },
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
                            child: Container(
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight.withOpacity(0.2)
                                    : AppColors.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusM),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      student.adSoyad.isNotEmpty
                                          ? student.adSoyad[0].toUpperCase()
                                          : 'Ö',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      student.adSoyad,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingM),
                      child: Text('Henüz bağlı öğrenci yok'),
                    ),
                  ),
              ],
            ),
          ),
          // Analiz İçeriği
          Expanded(
            child: _selectedStudentId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Analiz görmek için bir öğrenci seçin',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : analysisState.isLoading
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
                                      'Bu öğrenci için henüz analiz verisi yok',
                                      style: AppTextStyles.body1.copyWith(
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
                                  final progressList = analysis
                                      .learningOutcomeProgress.values
                                      .toList()
                                    ..sort((a, b) =>
                                        b.completedQuestions
                                            .compareTo(a.completedQuestions));

                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      ref
                                          .read(
                                              teacherStudentAnalysisProvider
                                                  .notifier)
                                          .loadStudentAnalysis(_selectedStudentId!);
                                    },
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(
                                          AppConstants.paddingM),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Genel İstatistikler
                                          AppCard(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Genel İstatistikler',
                                                  style: AppTextStyles.h5
                                                      .copyWith(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                                      color: _getSuccessColor(
                                                          analysis
                                                              .overallSuccessPercentage),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              height: AppConstants.paddingL),
                                          // Kazanım Bazlı Analiz
                                          Text(
                                            'Kazanım Bazlı Analiz',
                                            style: AppTextStyles.h5.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: AppConstants.paddingM),
                                          ...progressList.map((progress) =>
                                              _LearningOutcomeCard(
                                                  progress: progress)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                label: 'Çözülen',
                value: '${progress.completedQuestions}',
                icon: Icons.check_circle_outline,
                color: AppColors.info,
              ),
              _DetailStatItem(
                label: 'Doğru',
                value: '${progress.correctAnswers}',
                icon: Icons.check_circle,
                color: AppColors.success,
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


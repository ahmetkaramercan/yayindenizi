import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/section_analysis_provider.dart';
import '../../../domain/entities/student_analysis.dart';

class SectionAnalysisPage extends ConsumerWidget {
  final String sectionId;
  final String sectionTitle;
  final String bookTitle;

  const SectionAnalysisPage({
    super.key,
    required this.sectionId,
    required this.sectionTitle,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(sectionAnalysisProvider(sectionId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$sectionTitle - Seviye Analizim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(sectionAnalysisProvider(sectionId).notifier).loadAnalysis();
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
                : analysisState.analysis == null ||
                        analysisState.analysis!.learningOutcomeProgress.isEmpty
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
                              'Henüz seviye analizi yok',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bu seviyede test çözdükçe kazanım analizi burada görünecek',
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
                          final progressList = analysis
                              .learningOutcomeProgress.values
                              .toList()
                            ..sort((a, b) =>
                                b.completedQuestions.compareTo(a.completedQuestions));

                          // En çok yanlış yapılan (videoUrl'ı olan) kazanımlar
                          final videoRecommendations = (analysis
                                  .learningOutcomeProgress.values
                                  .toList()
                                ..sort((a, b) => b.incorrectAnswers
                                    .compareTo(a.incorrectAnswers)))
                              .where((p) =>
                                  p.learningOutcome.videoUrl != null &&
                                  p.incorrectAnswers > 0)
                              .take(3)
                              .toList();

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppCard(
                                  child: Column(
                                    children: [
                                      Text(
                                        '$bookTitle - $sectionTitle',
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
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
                                            color: _getSuccessColor(
                                                analysis.overallSuccessPercentage),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (videoRecommendations.isNotEmpty) ...[
                                  const SizedBox(height: AppConstants.paddingL),
                                  _VideoRecommendationsSection(
                                    recommendations: videoRecommendations,
                                  ),
                                ],
                                const SizedBox(height: AppConstants.paddingL),
                                Text(
                                  'Kazanım Bazlı Analiz',
                                  style: AppTextStyles.h5.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
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

class _VideoRecommendationsSection extends StatelessWidget {
  final List<LearningOutcomeProgress> recommendations;

  const _VideoRecommendationsSection({required this.recommendations});

  String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    return uri.queryParameters['v'] ?? '';
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            Text(
              'Sana Özel Videolar',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'En çok yanlış yaptığın konulara özel ders videoları',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...recommendations.map((p) {
          final videoUrl = p.learningOutcome.videoUrl!;
          final videoId = _extractVideoId(videoUrl);
          final thumbnailUrl =
              'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppConstants.paddingM),
            child: InkWell(
              onTap: () => _openVideo(videoUrl),
              borderRadius: BorderRadius.circular(12),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            thumbnailUrl,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 80,
                              color: AppColors.error.withValues(alpha: 0.1),
                              child: Icon(Icons.play_circle_outline,
                                  color: AppColors.error, size: 36),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 80,
                            color: Colors.black26,
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.learningOutcome.name,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.cancel,
                                    size: 14, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  '${p.incorrectAnswers} yanlış',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.2),
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
                          .withValues(alpha: 0.2),
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

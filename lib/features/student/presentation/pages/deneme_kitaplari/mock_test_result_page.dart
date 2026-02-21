import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../providers/mock_test_provider.dart';

class MockTestResultPage extends ConsumerWidget {
  const MockTestResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(mockTestProvider);
    final result = testState.currentResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Test Sonucu'),
        ),
        body: const Center(
          child: Text('Sonuç bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başarı Kartı
            AppCard(
              child: Column(
                children: [
                  Text(
                    result.testTitle,
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: result.successPercentage / 100,
                          strokeWidth: 12,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSuccessColor(result.successPercentage),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${result.successPercentage.toInt()}%',
                              style: AppTextStyles.h3.copyWith(
                                color: _getSuccessColor(result.successPercentage),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${result.correctAnswers}/${result.totalQuestions}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // İstatistikler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Doğru',
                        value: '${result.correctAnswers}',
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                      _StatItem(
                        label: 'Yanlış',
                        value: '${result.wrongAnswers}',
                        color: AppColors.error,
                        icon: Icons.cancel_outlined,
                      ),
                      _StatItem(
                        label: 'Boş',
                        value: '${result.emptyAnswers}',
                        color: AppColors.warning,
                        icon: Icons.remove_circle_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            // Butonlar
            AppButton(
              text: 'Genel Analize Git',
              icon: Icons.analytics_outlined,
              onPressed: () {
                context.pushReplacement('/student/deneme-kitaplari/analysis');
              },
              type: AppButtonType.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppConstants.paddingM),
            AppButton(
              text: 'Test Listesine Dön',
              icon: Icons.list,
              onPressed: () {
                ref.read(mockTestProvider.notifier).resetCurrentTest();
                context.pushReplacement('/student/deneme-kitaplari');
              },
              type: AppButtonType.outline,
              isFullWidth: true,
            ),
          ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
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



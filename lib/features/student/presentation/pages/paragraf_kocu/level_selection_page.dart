import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/cards/app_card.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../providers/test_provider.dart';

class LevelSelectionPage extends ConsumerWidget {
  const LevelSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = List.generate(8, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paragraf Koçu'),
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
            Text(
              'Seviye Seçin',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '8 farklı zorluk seviyesinden birini seçerek test çözebilirsiniz',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingM,
                mainAxisSpacing: AppConstants.paddingM,
                childAspectRatio: 1.2,
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return _LevelCard(
                  level: level,
                  onTap: () {
                    context.push('/student/paragraf-kocu/test', extra: level);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getLevelColor(level).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$level',
                style: AppTextStyles.h3.copyWith(
                  color: _getLevelColor(level),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            'Seviye $level',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getLevelDescription(level),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return AppColors.success;
    if (level <= 4) return AppColors.info;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  String _getLevelDescription(int level) {
    if (level <= 2) return 'Başlangıç';
    if (level <= 4) return 'Orta';
    if (level <= 6) return 'İleri';
    return 'Uzman';
  }
}


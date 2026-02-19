import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../providers/topic_provider.dart';

class TopicTestPage extends ConsumerStatefulWidget {
  final String testId;

  const TopicTestPage({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<TopicTestPage> createState() => _TopicTestPageState();
}

class _TopicTestPageState extends ConsumerState<TopicTestPage> {
  int _currentQuestionIndex = 0;
  final Map<String, int?> _answers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topicProvider.notifier).loadTopicTest(widget.testId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicState = ref.watch(topicProvider);
    final currentTest = topicState.currentTopicTest;

    if (topicState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konu Testi'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (topicState.error != null || currentTest == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konu Testi'),
        ),
        body: Center(
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
                topicState.error ?? 'Test bulunamadı',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Geri Dön',
                onPressed: () => context.pop(),
                type: AppButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = currentTest.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == currentTest.questions.length - 1;
    final selectedAnswer = _answers[currentQuestion.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTest.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru ${_currentQuestionIndex + 1} / ${currentTest.questions.length}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / currentTest.questions.length * 100).toInt()}%',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) /
                      currentTest.questions.length,
                  backgroundColor: AppColors.border,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
          // Question Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Text
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Text(
                      currentQuestion.text,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedAnswer == index;

                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppConstants.paddingM),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[currentQuestion.id] = index;
                          });
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
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.textOnPrimary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Text(
                                  '${String.fromCharCode(65 + index)}. $option',
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Önceki',
                      icon: Icons.arrow_back,
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      type: AppButtonType.outline,
                    ),
                  ),
                if (_currentQuestionIndex > 0)
                  const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: isLastQuestion ? 'Testi Bitir' : 'Sonraki',
                    icon: isLastQuestion ? Icons.check : Icons.arrow_forward,
                    onPressed: selectedAnswer != null
                        ? () {
                            if (isLastQuestion) {
                              _finishTest(context);
                            } else {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            }
                          }
                        : null,
                    isFullWidth: true,
                    type: AppButtonType.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Testi Sonlandır'),
        content: const Text(
            'Testi sonlandırmak istediğinize emin misiniz? İlerlemeniz kaydedilmeyecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Evet, Çık',
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            type: AppButtonType.danger,
          ),
        ],
      ),
    );
  }

  void _finishTest(BuildContext context) {
    final topicState = ref.read(topicProvider);
    final test = topicState.currentTopicTest!;

    // Test sonuçlarını hesapla
    ref.read(topicProvider.notifier).finishTopicTest(_answers);

    // Sonuç sayfasına yönlendir
    context.pushReplacement('/student/konu-kitaplari/test-result');
  }
}



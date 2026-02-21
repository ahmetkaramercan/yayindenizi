import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

const _optionLabels = ['A', 'B', 'C', 'D', 'E'];

class OpticalForm extends StatelessWidget {
  final int questionCount;
  final Map<int, int?> answers;
  final ValueChanged<MapEntry<int, int>> onAnswerChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const OpticalForm({
    super.key,
    required this.questionCount,
    required this.answers,
    required this.onAnswerChanged,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount = answers.values.where((v) => v != null).length;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingS,
          ),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$answeredCount / $questionCount cevaplandı',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    _optionLabels[i],
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Question grid
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
            itemCount: questionCount,
            itemBuilder: (context, index) {
              final selectedOption = answers[index];
              return _QuestionRow(
                questionNumber: index + 1,
                selectedOption: selectedOption,
                onOptionSelected: (optionIndex) {
                  onAnswerChanged(MapEntry(index, optionIndex));
                },
              );
            },
          ),
        ),
        // Submit button
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Testi Bitir ($answeredCount/$questionCount)',
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final int questionNumber;
  final int? selectedOption;
  final ValueChanged<int> onOptionSelected;

  const _QuestionRow({
    required this.questionNumber,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: questionNumber % 2 == 0
            ? AppColors.surface
            : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$questionNumber.',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (i) {
                final isSelected = selectedOption == i;
                return GestureDetector(
                  onTap: () => onOptionSelected(i),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _optionLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optik form sonuç sayfası
class OpticalFormResult extends StatelessWidget {
  final int questionCount;
  final Map<int, int?> studentAnswers;
  final Map<int, int> correctAnswers;
  final VoidCallback onClose;

  const OpticalFormResult({
    super.key,
    required this.questionCount,
    required this.studentAnswers,
    required this.correctAnswers,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    int correct = 0;
    int wrong = 0;
    int empty = 0;

    for (int i = 0; i < questionCount; i++) {
      final answer = studentAnswers[i];
      if (answer == null) {
        empty++;
      } else if (answer == correctAnswers[i]) {
        correct++;
      } else {
        wrong++;
      }
    }

    return Column(
      children: [
        // Score header
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          color: AppColors.primary,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScoreBadge(label: 'Doğru', count: correct, color: Colors.green),
                _ScoreBadge(label: 'Yanlış', count: wrong, color: Colors.red),
                _ScoreBadge(label: 'Boş', count: empty, color: Colors.grey),
              ],
            ),
          ),
        ),
        // Result grid
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
            itemCount: questionCount,
            itemBuilder: (context, index) {
              final studentAnswer = studentAnswers[index];
              final correctAnswer = correctAnswers[index] ?? -1;

              _AnswerStatus status;
              if (studentAnswer == null) {
                status = _AnswerStatus.empty;
              } else if (studentAnswer == correctAnswer) {
                status = _AnswerStatus.correct;
              } else {
                status = _AnswerStatus.wrong;
              }

              return _ResultRow(
                questionNumber: index + 1,
                studentAnswer: studentAnswer,
                correctAnswer: correctAnswer,
                status: status,
              );
            },
          ),
        ),
        // Close button
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: Text('Kapat', style: AppTextStyles.button),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _AnswerStatus { correct, wrong, empty }

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 3),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final int questionNumber;
  final int? studentAnswer;
  final int correctAnswer;
  final _AnswerStatus status;

  const _ResultRow({
    required this.questionNumber,
    required this.studentAnswer,
    required this.correctAnswer,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (status) {
      _AnswerStatus.correct => Colors.green.withValues(alpha: 0.08),
      _AnswerStatus.wrong => Colors.red.withValues(alpha: 0.08),
      _AnswerStatus.empty => Colors.transparent,
    };

    final statusIcon = switch (status) {
      _AnswerStatus.correct => const Icon(Icons.check_circle, color: Colors.green, size: 20),
      _AnswerStatus.wrong => const Icon(Icons.cancel, color: Colors.red, size: 20),
      _AnswerStatus.empty => const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: 6,
      ),
      color: bgColor,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$questionNumber.',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          statusIcon,
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (i) {
                final isStudentAnswer = studentAnswer == i;
                final isCorrect = correctAnswer == i;

                Color bubbleColor;
                Color textColor;
                Color borderColor;

                if (isCorrect) {
                  bubbleColor = Colors.green;
                  textColor = Colors.white;
                  borderColor = Colors.green;
                } else if (isStudentAnswer && !isCorrect) {
                  bubbleColor = Colors.red;
                  textColor = Colors.white;
                  borderColor = Colors.red;
                } else {
                  bubbleColor = Colors.transparent;
                  textColor = AppColors.textSecondary;
                  borderColor = AppColors.border;
                }

                return Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubbleColor,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _optionLabels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

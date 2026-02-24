import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/mock_test_result.dart';
import '../../providers/mock_test_provider.dart';
import '../../widgets/optical_form.dart' show OpticalForm, OpticalFormResult, QuestionAnalysisItem;

class MockTestPage extends ConsumerStatefulWidget {
  final String testId;

  const MockTestPage({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<MockTestPage> createState() => _MockTestPageState();
}

class _MockTestPageState extends ConsumerState<MockTestPage> {
  final Map<int, int?> _answers = {};
  bool _showResult = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mockTestProvider.notifier).loadTest(widget.testId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(mockTestProvider);

    if (testState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deneme Testi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (testState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deneme Testi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(testState.error!, style: AppTextStyles.body1),
              const SizedBox(height: 24),
              TextButton(onPressed: () => context.pop(), child: const Text('Geri Dön')),
            ],
          ),
        ),
      );
    }

    final test = testState.currentTest;
    if (test == null || test.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deneme Testi')),
        body: const Center(child: Text('Test bulunamadı')),
      );
    }

    if (testState.alreadySolved && testState.currentResult != null) {
      final correctMap = <int, int>{};
      final savedAnswers = <int, int?>{};
      for (int i = 0; i < test.questions.length; i++) {
        correctMap[i] = test.questions[i].correctAnswerIndex;
        final answer = testState.currentResult!.answers.where(
          (a) => a.questionId == test.questions[i].id,
        );
        if (answer.isNotEmpty) {
          savedAnswers[i] = answer.first.selectedAnswerIndex;
        }
      }

      final result = testState.currentResult!;
      final questionDetails = _buildQuestionAnalysisDetails(test, result, savedAnswers, correctMap);

      return Scaffold(
        appBar: AppBar(title: Text('${test.title} - Sonuç')),
        body: OpticalFormResult(
          questionCount: test.questions.length,
          studentAnswers: savedAnswers,
          correctAnswers: correctMap,
          onClose: () {
            ref.read(mockTestProvider.notifier).resetCurrentTest();
            context.pop();
          },
          questionAnalysisDetails: questionDetails,
        ),
      );
    }

    if (_showResult && testState.currentResult != null) {
      final correctMap = <int, int>{};
      for (int i = 0; i < test.questions.length; i++) {
        correctMap[i] = test.questions[i].correctAnswerIndex;
      }

      final result = testState.currentResult!;
      final questionDetails = _buildQuestionAnalysisDetails(test, result, _answers, correctMap);

      return Scaffold(
        appBar: AppBar(title: Text('${test.title} - Sonuç')),
        body: OpticalFormResult(
          questionCount: test.questions.length,
          studentAnswers: _answers,
          correctAnswers: correctMap,
          onClose: () {
            ref.read(mockTestProvider.notifier).resetCurrentTest();
            context.pop();
          },
          questionAnalysisDetails: questionDetails,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(test.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: OpticalForm(
        questionCount: test.questions.length,
        answers: _answers,
        isSubmitting: _isSubmitting,
        onAnswerChanged: (entry) {
          setState(() {
            if (_answers[entry.key] == entry.value) {
              _answers.remove(entry.key);
            } else {
              _answers[entry.key] = entry.value;
            }
          });
        },
        onSubmit: () => _finishTest(),
      ),
    );
  }

  void _finishTest() {
    final test = ref.read(mockTestProvider).currentTest;
    if (test == null) return;

    setState(() => _isSubmitting = true);

    final questionAnswers = <String, int?>{};
    for (int i = 0; i < test.questions.length; i++) {
      questionAnswers[test.questions[i].id] = _answers[i];
    }

    ref.read(mockTestProvider.notifier).finishTest(questionAnswers);

    setState(() {
      _isSubmitting = false;
      _showResult = true;
    });
  }

  List<QuestionAnalysisItem> _buildQuestionAnalysisDetails(
    dynamic test,
    dynamic result,
    Map<int, int?> studentAnswers,
    Map<int, int> correctAnswers,
  ) {
    final answerByQuestionId = <String, bool>{};
    for (final a in result.answers) {
      answerByQuestionId[a.questionId as String] = a.status == AnswerStatus.correct;
    }
    final items = <QuestionAnalysisItem>[];
    for (var i = 0; i < test.questions.length; i++) {
      final q = test.questions[i];
      final outcomeName = q.learningOutcome?.name ?? 'Genel';
      final isCorrect = answerByQuestionId[q.id] ?? false;
      items.add(QuestionAnalysisItem(
        questionNumber: i + 1,
        outcomeName: outcomeName,
        isCorrect: isCorrect,
      ));
    }
    return items;
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Testi Sonlandır'),
        content: const Text('Testi sonlandırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Evet, Çık'),
          ),
        ],
      ),
    );
  }
}

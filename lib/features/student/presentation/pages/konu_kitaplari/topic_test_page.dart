import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../providers/topic_provider.dart';
import '../../widgets/optical_form.dart' show OpticalForm, OpticalFormResult, QuestionAnalysisItem;

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
  final Map<int, int?> _answers = {};
  bool _showResult = false;
  bool _isSubmitting = false;

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

    if (topicState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konu Testi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (topicState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konu Testi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(topicState.error!, style: AppTextStyles.body1),
              const SizedBox(height: 24),
              TextButton(onPressed: () => context.pop(), child: const Text('Geri Dön')),
            ],
          ),
        ),
      );
    }

    final test = topicState.currentTopicTest;
    if (test == null || test.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konu Testi')),
        body: const Center(child: Text('Test bulunamadı')),
      );
    }

    if (topicState.alreadySolved && topicState.currentTopicResult != null) {
      final correctMap = <int, int>{};
      final savedAnswers = <int, int?>{};
      for (int i = 0; i < test.questions.length; i++) {
        correctMap[i] = test.questions[i].correctAnswerIndex;
        final answer = topicState.currentTopicResult!.answers.where(
          (a) => a.questionId == test.questions[i].id,
        );
        if (answer.isNotEmpty) {
          savedAnswers[i] = answer.first.selectedAnswerIndex;
        }
      }

      final result = topicState.currentTopicResult!;
      final questionDetails = _buildQuestionAnalysisDetails(test, result, savedAnswers, correctMap);

      return Scaffold(
        appBar: AppBar(title: Text('${test.title} - Sonuç')),
        body: OpticalFormResult(
          questionCount: test.questions.length,
          studentAnswers: savedAnswers,
          correctAnswers: correctMap,
          onClose: () {
            ref.read(topicProvider.notifier).resetCurrentTest();
            context.pop();
          },
          questionAnalysisDetails: questionDetails,
        ),
      );
    }

    if (_showResult && topicState.currentTopicResult != null) {
      final correctMap = <int, int>{};
      for (int i = 0; i < test.questions.length; i++) {
        correctMap[i] = test.questions[i].correctAnswerIndex;
      }

      final result = topicState.currentTopicResult!;
      final questionDetails = _buildQuestionAnalysisDetails(test, result, _answers, correctMap);

      return Scaffold(
        appBar: AppBar(title: Text('${test.title} - Sonuç')),
        body: OpticalFormResult(
          questionCount: test.questions.length,
          studentAnswers: _answers,
          correctAnswers: correctMap,
          onClose: () {
            ref.read(topicProvider.notifier).resetCurrentTest();
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
    final test = ref.read(topicProvider).currentTopicTest;
    if (test == null) return;

    setState(() => _isSubmitting = true);

    final questionAnswers = <String, int?>{};
    for (int i = 0; i < test.questions.length; i++) {
      questionAnswers[test.questions[i].id] = _answers[i];
    }

    ref.read(topicProvider.notifier).finishTopicTest(questionAnswers);

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
      answerByQuestionId[a.questionId as String] = a.isCorrect as bool;
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

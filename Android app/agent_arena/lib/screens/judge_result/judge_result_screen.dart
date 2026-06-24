import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../providers/history_provider.dart';
import '../../widgets/judge/judge_result_card.dart';
import '../../widgets/debate/winner_banner.dart';
import '../../widgets/debate/score_chart.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_error_widget.dart';

class JudgeResultScreen extends ConsumerWidget {
  final String debateId;

  const JudgeResultScreen({super.key, required this.debateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(debateDetailProvider(debateId));

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: detailAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading results...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(debateDetailProvider(debateId)),
        ),
        data: (detail) {
          final judgeResult = detail.judgeResult;
          if (judgeResult == null) {
            return const Center(
              child: Text(
                'No judge result available yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final scores = <String, double>{};
          for (final entry in detail.voteCount.entries) {
            scores[entry.key] = entry.value.toDouble();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                WinnerBanner(
                  winner: judgeResult.winner,
                  explanation: judgeResult.explanation,
                ),
                const SizedBox(height: 20),
                JudgeResultCard(result: judgeResult),
                if (scores.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ScoreChart(scores: scores),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rambahaur,
                    ),
                    child: const Text('New Debate'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

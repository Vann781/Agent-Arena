import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/history_provider.dart';
import '../../widgets/debate/agent_response_card.dart';
import '../../widgets/debate/reasoning_tree.dart';
import '../../widgets/judge/judge_result_card.dart';
import '../../widgets/debate/score_chart.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_error_widget.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String debateId;

  const HistoryDetailScreen({super.key, required this.debateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(debateDetailProvider(debateId));

    return Scaffold(
      appBar: AppBar(title: const Text('Debate Details')),
      body: detailAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading debate...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(debateDetailProvider(debateId)),
        ),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.topic,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoChip(detail.status, AppColors.cyan),
                        const SizedBox(width: 8),
                        _infoChip(
                          detail.chaosMode ? 'Chaos Mode' : 'Standard',
                          detail.chaosMode ? AppColors.pink : AppColors.purple,
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatShortDate(detail.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (detail.judgeResult != null) ...[
                const SizedBox(height: 20),
                JudgeResultCard(result: detail.judgeResult!),
                if (detail.voteCount.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ScoreChart(
                    scores: detail.voteCount.map(
                      (k, v) => MapEntry(k, v.toDouble()),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              const Text(
                'Rounds',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...detail.rounds.asMap().entries.map((entry) {
                final i = entry.key;
                final round = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Round ${i + 1}',
                        style: const TextStyle(
                          color: AppColors.rambahaur,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ...(round['responses'] as List?)?.map((r) {
                          final agentId = r['agent_id'] as String? ?? '';
                          final side = r['side'] as String? ?? '';
                          final response = r['response'] as String? ?? '';
                          final reasoning =
                              (r['reasoning_path'] as List?)
                                  ?.map((e) => e.toString())
                                  .toList() ??
                              [];
                          return Column(
                            children: [
                              AgentResponseCard(
                                agentId: agentId,
                                side: side,
                                response: response,
                              ),
                              if (reasoning.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ReasoningTree(
                                    reasoningPath: reasoning,
                                  ),
                                ),
                            ],
                          );
                        }) ??
                        [],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

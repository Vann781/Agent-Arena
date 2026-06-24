import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../providers/debate_provider.dart';
import '../../providers/vote_provider.dart';
import '../../widgets/debate/debate_header.dart';
import '../../widgets/debate/agent_response_card.dart';
import '../../widgets/debate/question_input.dart';
import '../../widgets/debate/vote_button.dart';
import '../../widgets/debate/reasoning_tree.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_error_widget.dart';

class DebateScreen extends ConsumerWidget {
  final String debateId;

  const DebateScreen({super.key, required this.debateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debateState = ref.watch(debateProvider);

    if (debateState.status == DebateStatus.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debate')),
        body: const LoadingIndicator(message: 'Loading debate...'),
      );
    }

    if (debateState.status == DebateStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debate')),
        body: AppErrorWidget(
          message: debateState.error ?? 'An error occurred',
          onRetry: () => ref.read(debateProvider.notifier).advanceRound(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(debateState.topic ?? 'Debate'),
        actions: [
          if (debateState.isComplete)
            TextButton(
              onPressed: () => context.go('/debate/$debateId/result'),
              child: const Text(
                'Results',
                style: TextStyle(color: AppColors.cyan),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (debateState.topic != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DebateHeader(
                topic: debateState.topic!,
                currentRound: debateState.currentRound,
                maxRounds: debateState.structure?.length ?? 4,
                phase: '',
                agents: debateState.agents,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: debateState.rounds.length + 1,
              itemBuilder: (_, i) {
                if (i < debateState.rounds.length) {
                  final round = debateState.rounds[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Round ${round.roundNumber} - ${round.phase.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...round.responses.map(
                        (r) => Column(
                          children: [
                            AgentResponseCard(
                              agentId: r.agentId,
                              side: r.side,
                              response: r.response,
                              isLatest: i == debateState.rounds.length - 1,
                            ),
                            if (r.reasoningPath.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ReasoningTree(
                                  reasoningPath: r.reasoningPath,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!debateState.isComplete)
                        ElevatedButton.icon(
                          onPressed: debateState.status == DebateStatus.loading
                              ? null
                              : () => ref
                                    .read(debateProvider.notifier)
                                    .advanceRound(),
                          icon: Icon(
                            debateState.status == DebateStatus.loading
                                ? Icons.hourglass_top
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            debateState.status == DebateStatus.loading
                                ? 'Processing...'
                                : 'Next Round',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Column(
              children: [
                if (debateState.rounds.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: debateState.rounds.last.responses
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: VoteButton(
                                agentId: r.agentId,
                                voteCount: 0,
                                isSelected: false,
                                onTap: () => ref
                                    .read(voteProvider.notifier)
                                    .vote(debateId, r.agentId),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                QuestionInput(
                  onSubmitted: (q, target) => ref
                      .read(debateProvider.notifier)
                      .askQuestion(q, targetAgent: target),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/validators.dart';
import '../../models/chaos_model.dart';
import '../../providers/debate_provider.dart';
import '../../widgets/common/glassmorphism_card.dart';
import '../../widgets/common/animated_gradient_text.dart';

class ChaosModeScreen extends ConsumerStatefulWidget {
  const ChaosModeScreen({super.key});

  @override
  ConsumerState<ChaosModeScreen> createState() => _ChaosModeScreenState();
}

class _ChaosModeScreenState extends ConsumerState<ChaosModeScreen> {
  final _topicController = TextEditingController();
  final _agentControllers = List.generate(4, (_) => TextEditingController());
  int _maxRounds = 4;

  static const _agentDefaults = [
    'Optimist',
    'Pessimist',
    'Engineer',
    'Economist',
  ];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _agentControllers[i].text = _agentDefaults[i];
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    for (final c in _agentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startChaos() {
    final topic = _topicController.text.trim();
    final topicError = Validators.validateTopic(topic);
    if (topicError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(topicError), backgroundColor: AppColors.error),
      );
      return;
    }

    final agents = _agentControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (agents.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 2 agents required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = ChaosModeRequest(
      topic: topic,
      agents: agents,
      maxRounds: _maxRounds,
    );

    ref.read(debateProvider.notifier).startChaos(request);
  }

  @override
  Widget build(BuildContext context) {
    final debateState = ref.watch(debateProvider);

    ref.listen<DebateState>(debateProvider, (_, next) {
      if (next.status == DebateStatus.active && next.debateId != null) {
        context.go('/debate/${next.debateId}');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chaos Mode')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AnimatedGradientText(
              text: 'Chaos Mode',
              colors: [AppColors.pink, AppColors.amber, AppColors.purple],
              fontSize: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Custom agents, custom mayhem',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            GlassmorphismCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debate Topic',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topicController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter a chaotic debate topic...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Agents',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Name 2-4 agents',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _agentControllers[i],
                        decoration: InputDecoration(
                          hintText: 'Agent ${i + 1}',
                          prefixIcon: Icon(
                            Icons.smart_toy,
                            color: [
                              AppColors.cyan,
                              AppColors.pink,
                              AppColors.amber,
                              AppColors.purple,
                            ][i],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Row(
                children: [
                  const Text(
                    'Rounds:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: Slider(
                      value: _maxRounds.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      activeColor: AppColors.pink,
                      inactiveColor: AppColors.surfaceLight,
                      label: '$_maxRounds',
                      onChanged: (v) => setState(() => _maxRounds = v.round()),
                    ),
                  ),
                  Text(
                    '$_maxRounds',
                    style: const TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: debateState.status == DebateStatus.loading
                    ? null
                    : _startChaos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                ),
                child: debateState.status == DebateStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Text('Start Chaos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

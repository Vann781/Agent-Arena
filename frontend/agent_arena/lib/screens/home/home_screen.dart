import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/glassmorphism_card.dart';
import '../../widgets/common/animated_gradient_text.dart';
import '../../providers/debate_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _topicController = TextEditingController();
  int _maxRounds = 4;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _startDebate() {
    final topic = _topicController.text.trim();
    final error = Validators.validateTopic(topic);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
      return;
    }
    ref.read(debateProvider.notifier).startDebate(topic, maxRounds: _maxRounds);
  }

  @override
  Widget build(BuildContext context) {
    final debateState = ref.watch(debateProvider);

    ref.listen<DebateState>(debateProvider, (_, next) {
      if (next.status == DebateStatus.active && next.debateId != null) {
        context.go('/debate/${next.debateId}');
      }
      if (next.status == DebateStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const AnimatedGradientText(
                text: 'Agent Arena',
                colors: [AppColors.cyan, AppColors.purple, AppColors.pink],
                fontSize: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'Multi-Agent AI Debate Platform',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              GlassmorphismCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start a Debate',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _topicController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Debate Topic',
                        hintText:
                            'e.g., AI will replace all software engineers',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Rounds:',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: Slider(
                            value: _maxRounds.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: AppColors.cyan,
                            inactiveColor: AppColors.surfaceLight,
                            label: '$_maxRounds',
                            onChanged: (v) =>
                                setState(() => _maxRounds = v.round()),
                          ),
                        ),
                        Text(
                          '$_maxRounds',
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: debateState.status == DebateStatus.loading
                            ? null
                            : _startDebate,
                        child: debateState.status == DebateStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : const Text('Start Debate'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphismCard(
                      onTap: () => context.push('/history'),
                      child: const Column(
                        children: [
                          Icon(Icons.history, color: AppColors.cyan, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'History',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphismCard(
                      onTap: () => context.push('/chaos'),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppColors.pink,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chaos Mode',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphismCard(
                      onTap: () => context.push('/profile'),
                      child: const Column(
                        children: [
                          Icon(Icons.person, color: AppColors.purple, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Profile',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

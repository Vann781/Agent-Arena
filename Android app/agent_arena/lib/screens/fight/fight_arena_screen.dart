import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../providers/debate_provider.dart';
import '../../services/sound_manager.dart';
import '../../widgets/fight/arena_background.dart';
import '../../widgets/fight/fighter_sprite.dart' as fight;
import '../../widgets/fight/health_bar.dart';
import '../../widgets/fight/speech_bubble.dart';
import '../../widgets/fight/winner_overlay.dart';

class FightArenaScreen extends ConsumerStatefulWidget {
  final String debateId;

  const FightArenaScreen({super.key, required this.debateId});

  @override
  ConsumerState<FightArenaScreen> createState() => _FightArenaScreenState();
}

class _FightArenaScreenState extends ConsumerState<FightArenaScreen>
    with TickerProviderStateMixin {
  final SoundManager _sound = SoundManager();
  fight.FighterState _proState = fight.FighterState.idle;
  fight.FighterState _conState = fight.FighterState.idle;
  double _proHp = 100;
  double _conHp = 100;
  String? _proText;
  String? _conText;
  bool _showJudge = false;
  bool _showWinner = false;
  String _winner = '';
  double _winnerScore = 0;
  double _loserScore = 0;
  bool _matchStarted = false;
  int _processingRound = 0;

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  Future<void> _startMatch() async {
    await _sound.playBegin();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _matchStarted = true);
    await _sound.playFight();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) _triggerNextRound();
  }

  Future<void> _triggerNextRound() async {
    final notifier = ref.read(debateProvider.notifier);
    setState(() => _processingRound = 1);
    await notifier.advanceRound();
    _animateRound();
  }

  void _animateRound() {
    final state = ref.read(debateProvider);
    if (state.rounds.isEmpty) return;
    final round = state.rounds.last;

    setState(() => _processingRound = 0);

    _animateAgent(
      'pro',
      round.responses.where((r) => r.agentId == 'pro').firstOrNull?.response ??
          '',
      () async {
        if (!mounted) return;
        _proText =
            round.responses
                .where((r) => r.agentId == 'pro')
                .firstOrNull
                ?.response ??
            '';
        _proState = fight.FighterState.attacking;
        setState(() {});
        await _sound.playSwordSwing();
        final tone =
            round.responses
                .where((r) => r.agentId == 'pro')
                .firstOrNull
                ?.tone ??
            '';
        if (tone == 'sarcastic') {
          await Future.delayed(const Duration(milliseconds: 200));
          await _sound.playSarcasm();
        }
        _proHp -=
            (10 -
                (round.responses
                            .where((r) => r.agentId == 'pro')
                            .firstOrNull
                            ?.tone ==
                        'aggressive'
                    ? 7
                    : 6)) *
            5;
        await Future.delayed(const Duration(seconds: 3));
        _proState = fight.FighterState.idle;
        setState(() {});
      },
    );

    _animateAgent(
      'con',
      round.responses.where((r) => r.agentId == 'con').firstOrNull?.response ??
          '',
      () async {
        if (!mounted) return;
        _conText =
            round.responses
                .where((r) => r.agentId == 'con')
                .firstOrNull
                ?.response ??
            '';
        _conState = fight.FighterState.attacking;
        setState(() {});
        await _sound.playSwordSwing();
        final tone =
            round.responses
                .where((r) => r.agentId == 'con')
                .firstOrNull
                ?.tone ??
            '';
        if (tone == 'sarcastic') {
          await Future.delayed(const Duration(milliseconds: 200));
          await _sound.playSarcasm();
        }
        _conHp -=
            (10 -
                (round.responses
                            .where((r) => r.agentId == 'con')
                            .firstOrNull
                            ?.tone ==
                        'sarcastic'
                    ? 7
                    : 6)) *
            5;
        await Future.delayed(const Duration(seconds: 3));
        _conState = fight.FighterState.idle;
        setState(() {});
      },
    );

    _animateJudge();

    if (state.isComplete) {
      Future.delayed(const Duration(seconds: 3), () {
        final winner = round.responses.isNotEmpty
            ? round.responses.first.agentId
            : 'pro';
        setState(() {
          _winner = winner;
          _winnerScore = 70;
          _loserScore = 50;
          _showWinner = true;
          if (winner == 'pro') {
            _proState = fight.FighterState.victory;
            _conState = fight.FighterState.defeated;
          } else {
            _conState = fight.FighterState.victory;
            _proState = fight.FighterState.defeated;
          }
        });
      });
    }
  }

  void _animateAgent(String id, String text, Future<void> Function() cb) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await cb();
  }

  void _animateJudge() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _showJudge = true);
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debateProvider);

    return Scaffold(
      body: Stack(
        children: [
          const ArenaBackground(),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    state.topic ?? 'FIGHT!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _sound.muted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white70,
                    ),
                    onPressed: () =>
                        setState(() => _sound.muted = !_sound.muted),
                  ),
                ],
              ),
            ),
          ),
          // Health bars
          if (_matchStarted)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HealthBar(
                    percent: _proHp / 100,
                    color: AppColors.agentA,
                    label: 'PRO',
                  ),
                  HealthBar(
                    percent: _conHp / 100,
                    color: const Color(0xFFFF4081),
                    label: 'CON',
                  ),
                ],
              ),
            ),
          // Round banner
          if (_processingRound > 0)
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0, end: 1),
                builder: (_, val, __) => Opacity(
                  opacity: val,
                  child: const Text(
                    '⚔️ ROUND START! ⚔️',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              ),
            ),
          // Fighters
          if (_matchStarted) ...[
            Positioned(
              left: 20,
              bottom: 120,
              child: fight.FighterSprite(
                agentId: 'pro',
                spritePath: 'characters/agent_pro.png',
                state: _proState,
                isLeft: true,
                healthPercent: _proHp / 100,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 120,
              child: fight.FighterSprite(
                agentId: 'con',
                spritePath: 'characters/agent_con.png',
                state: _conState,
                isLeft: false,
                healthPercent: _conHp / 100,
              ),
            ),
          ],
          // Speech bubbles
          if (_proText != null && _proText!.isNotEmpty)
            Positioned(
              left: 20,
              bottom: 280,
              child: SpeechBubble(
                text: _proText!,
                color: AppColors.agentA,
                isLeft: true,
              ),
            ),
          if (_conText != null && _conText!.isNotEmpty)
            Positioned(
              right: 20,
              bottom: 280,
              child: SpeechBubble(
                text: _conText!,
                color: const Color(0xFFFF4081),
                isLeft: false,
              ),
            ),
          // Judge commentary
          if (_showJudge && state.rounds.isNotEmpty) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    state.rounds.last.responses.isNotEmpty
                        ? '⚡ JUDGE: What a clash!'
                        : '⚡ JUDGE: ...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Start banner before match
          if (!_matchStarted)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎌', style: TextStyle(fontSize: 80)),
                  SizedBox(height: 16),
                  Text(
                    'GET READY',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amber,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
          // Winner overlay
          if (_showWinner)
            WinnerOverlay(
              winner: _winner,
              winnerScore: _winnerScore,
              loserScore: _loserScore,
              soundManager: _sound,
            ),
        ],
      ),
    );
  }
}

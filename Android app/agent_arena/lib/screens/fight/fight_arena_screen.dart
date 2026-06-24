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
  String? _judgeText;
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
    _showJudge = false;
    _proText = null;
    _conText = null;
    await notifier.advanceRound();
    await _animateRound();
  }

  Future<void> _animateRound() async {
    final state = ref.read(debateProvider);
    if (state.rounds.isEmpty) return;
    final round = state.rounds.last;

    setState(() => _processingRound = 0);

    final proResp = round.responses
        .where((r) => r.agentId == 'pro')
        .firstOrNull;
    final conResp = round.responses
        .where((r) => r.agentId == 'con')
        .firstOrNull;

    // PRO turn
    await _animateAgent(() async {
      if (!mounted) return;
      _proText = proResp?.response ?? '';
      _proState = fight.FighterState.attacking;
      setState(() {});
      await _sound.playSwordSwing();
      if (proResp?.tone == 'sarcastic') {
        await Future.delayed(const Duration(seconds: 1));
      }
      _conHp -= proResp?.tone == 'aggressive' ? 35 : 25;
      await Future.delayed(const Duration(seconds: 2));
      _proState = fight.FighterState.idle;
      setState(() {});
    });

    // CON turn after PRO
    await _animateAgent(() async {
      if (!mounted) return;
      _conText = conResp?.response ?? '';
      _conState = fight.FighterState.attacking;
      setState(() {});
      await _sound.playSwordSwing();
      if (conResp?.tone == 'sarcastic') {
        await Future.delayed(const Duration(seconds: 1));
      }
      _proHp -= conResp?.tone == 'sarcastic' ? 35 : 25;
      await Future.delayed(const Duration(seconds: 2));
      _conState = fight.FighterState.idle;
      setState(() {});
    });

    // Judge
    await _animateJudge(round.judgeFeedback);

    // Winner
    if (state.isComplete) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _winner = round.responses.isNotEmpty
            ? round.responses.first.agentId
            : 'pro';
        _winnerScore = round.scorePro;
        _loserScore = round.scoreCon;
        _showWinner = true;
        if (_winner == 'pro') {
          _proState = fight.FighterState.victory;
          _conState = fight.FighterState.defeated;
        } else {
          _conState = fight.FighterState.victory;
          _proState = fight.FighterState.defeated;
        }
      });
    }
  }

  Future<void> _animateAgent(Future<void> Function() cb) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await cb();
  }

  Future<void> _animateJudge(String feedback) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _judgeText = feedback.isNotEmpty ? feedback : 'What a clash!';
      _showJudge = true;
    });
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debateProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final fighterBottom = screenHeight * 0.12;

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
              bottom: fighterBottom + bottomInset,
              child: fight.FighterSprite(
                agentId: 'pro',
                spritePath: 'assets/characters/agent_pro.png',
                state: _proState,
                isLeft: true,
                healthPercent: _proHp / 100,
              ),
            ),
            Positioned(
              right: 20,
              bottom: fighterBottom + bottomInset,
              child: fight.FighterSprite(
                agentId: 'con',
                spritePath: 'assets/characters/agent_con.png',
                state: _conState,
                isLeft: false,
                healthPercent: _conHp / 100,
              ),
            ),
          ],
          // Speech bubbles above fighters
          if (_proText != null && _proText!.isNotEmpty)
            Positioned(
              left: 20,
              bottom: fighterBottom + 180 + bottomInset,
              child: SpeechBubble(
                text: _proText!,
                color: AppColors.agentA,
                isLeft: true,
              ),
            ),
          if (_conText != null && _conText!.isNotEmpty)
            Positioned(
              right: 20,
              bottom: fighterBottom + 180 + bottomInset,
              child: SpeechBubble(
                text: _conText!,
                color: const Color(0xFFFF4081),
                isLeft: false,
              ),
            ),
          // Judge commentary
          if (_showJudge && _judgeText != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16 + bottomInset,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '⚡ JUDGE: $_judgeText',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/agent_names.dart';
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
  bool _roundInFlight = false;

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  Future<void> _startMatch() async {
    await _sound.playBegin();
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _matchStarted = true);
    await _sound.playFight();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _triggerNextRound();
  }

  Future<void> _triggerNextRound() async {
    if (_roundInFlight) return;
    if (ref.read(debateProvider).isComplete) return;
    _roundInFlight = true;

    final notifier = ref.read(debateProvider.notifier);
    setState(() {
      _processingRound = 1;
      _showJudge = false;
      _proText = null;
      _conText = null;
    });

    await notifier.advanceRound();
    if (!mounted) {
      _roundInFlight = false;
      return;
    }

    if (ref.read(debateProvider).status == DebateStatus.error) {
      setState(() => _processingRound = 0);
      _roundInFlight = false;
      return;
    }

    await _animateRound();
    _roundInFlight = false;

    if (mounted && !ref.read(debateProvider).isComplete) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) _triggerNextRound();
    }
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

    // Rambahaur turn
    await _animateAgent(() async {
      if (!mounted) return;
      _conText = null;
      _proText = proResp?.response ?? '';
      _proState = fight.FighterState.attacking;
      setState(() {});
      await _sound.playSwordSwing();
      if (proResp?.tone == 'sarcastic') {
        await _sound.playSarcasm();
        await Future.delayed(const Duration(seconds: 1));
      }
      _conHp = (_conHp - (proResp?.tone == 'aggressive' ? 35 : 25))
          .clamp(0, 100)
          .toDouble();
      await Future.delayed(const Duration(seconds: 2));
      _proState = fight.FighterState.idle;
      setState(() {});
    });

    // Shaam Bahadur turn
    await _animateAgent(() async {
      if (!mounted) return;
      _proText = null;
      _conText = conResp?.response ?? '';
      _conState = fight.FighterState.attacking;
      setState(() {});
      await _sound.playSwordSwing();
      if (conResp?.tone == 'sarcastic') {
        await _sound.playSarcasm();
        await Future.delayed(const Duration(seconds: 1));
      }
      _proHp =
          (_proHp -
                  ((conResp?.tone == 'aggressive' ||
                          conResp?.tone == 'sarcastic')
                      ? 35
                      : 25))
              .clamp(0, 100)
              .toDouble();
      await Future.delayed(const Duration(seconds: 2));
      _conState = fight.FighterState.idle;
      setState(() {});
    });

    // Judge
    await _animateJudge(round.judgeFeedback);

    if (!mounted) return;

    if (state.isComplete) {
      await _showFinalWinner();
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

  Future<void> _showFinalWinner() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final rounds = ref.read(debateProvider).rounds;

    double proTotal = 0;
    double conTotal = 0;
    for (final r in rounds) {
      proTotal += r.scorePro;
      conTotal += r.scoreCon;
    }
    final proWon = proTotal >= conTotal;

    setState(() {
      _winner = proWon ? 'pro' : 'con';
      _winnerScore = proWon ? proTotal : conTotal;
      _loserScore = proWon ? conTotal : proTotal;
      _showWinner = true;
      if (proWon) {
        _proState = fight.FighterState.victory;
        _conState = fight.FighterState.defeated;
      } else {
        _conState = fight.FighterState.victory;
        _proState = fight.FighterState.defeated;
      }
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go('/');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final fighterBottom = screenHeight * 0.12;

    return Scaffold(
      body: Stack(
        children: [
          const ArenaBackground(),
          // Top HUD — back button, round counter, mute
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white54),
                    onPressed: () => context.pop(),
                  ),
                  if (_matchStarted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.amber.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ROUND ${state.currentRound}',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _sound.muted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white54,
                    ),
                    onPressed: () =>
                        setState(() => _sound.muted = !_sound.muted),
                  ),
                ],
              ),
            ),
          ),
          // Health bars — Street Fighter style at very top
          if (_matchStarted)
            Positioned(
              top: 48,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  // Rambahaur (left)
                  HealthBar(
                    percent: _proHp / 100,
                    color: AppColors.rambahaur,
                    darkColor: AppColors.rambahaurDark,
                    label: displayName('pro'),
                    rightAligned: false,
                  ),
                  const Spacer(),
                  // Round indicator between bars
                  Container(
                    width: screenWidth * 0.15,
                    alignment: Alignment.center,
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Shaam Bahadur (right)
                  HealthBar(
                    percent: _conHp / 100,
                    color: AppColors.shaamBahadur,
                    darkColor: AppColors.shaamBahadurDark,
                    label: displayName('con'),
                    rightAligned: true,
                  ),
                ],
              ),
            ),
          // Round banner animation
          if (_processingRound > 0)
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0, end: 1),
                builder: (_, val, __) => Opacity(
                  opacity: val,
                  child: Text(
                    'ROUND ${state.currentRound} — FIGHT!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.amber,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
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
                accentColor: AppColors.rambahaur,
                nameColor: AppColors.rambahaur,
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
                accentColor: AppColors.shaamBahadur,
                nameColor: AppColors.shaamBahadur,
              ),
            ),
          ],
          // Speech bubbles above fighters
          if (_proText != null && _proText!.isNotEmpty)
            Positioned(
              left: 8,
              bottom: fighterBottom + 170 + bottomInset,
              child: SpeechBubble(
                text: _proText!,
                color: AppColors.rambahaur,
                isLeft: true,
                agentName: displayName('pro'),
              ),
            ),
          if (_conText != null && _conText!.isNotEmpty)
            Positioned(
              right: 8,
              bottom: fighterBottom + 170 + bottomInset,
              child: SpeechBubble(
                text: _conText!,
                color: AppColors.shaamBahadur,
                isLeft: false,
                agentName: displayName('con'),
              ),
            ),
          // Judge commentary — arcade ticker style
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
                    color: const Color(0xFF0D0D1A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _judgeText!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Start screen — VS splash
          if (!_matchStarted)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'RAMBAHAUR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.rambahaur,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: AppColors.rambahaur.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.amber,
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    'SHAAM BAHADUR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.shaamBahadur,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: AppColors.shaamBahadur.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'GET READY',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
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

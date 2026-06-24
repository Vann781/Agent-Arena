import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../services/sound_manager.dart';
import '../../core/constants/agent_names.dart';

class WinnerOverlay extends StatefulWidget {
  final String winner;
  final double winnerScore;
  final double loserScore;
  final SoundManager soundManager;

  const WinnerOverlay({
    super.key,
    required this.winner,
    required this.winnerScore,
    required this.loserScore,
    required this.soundManager,
  });

  @override
  State<WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<WinnerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _showKo = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    widget.soundManager.playVictory();
    _animCtrl.forward().then((_) => setState(() => _showKo = true));
    Future.delayed(const Duration(milliseconds: 900), () {
      widget.soundManager.playDefeat();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winnerName = displayName(widget.winner).toUpperCase();
    final winColor = widget.winner == 'pro'
        ? AppColors.rambahaur
        : AppColors.shaamBahadur;
    return Stack(
      children: [
        // Dark overlay with flash
        AnimatedBuilder(
          animation: _animCtrl,
          builder: (_, child) {
            final flash = sin(_animCtrl.value * pi * 3) * 0.3;
            return Container(
              color: Colors.black.withValues(
                alpha: 0.5 + _animCtrl.value * 0.3 - flash,
              ),
            );
          },
        ),
        // K.O. text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showKo)
                AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (_, __) {
                    final slam = _animCtrl.value < 0.3
                        ? (_animCtrl.value / 0.3) * 200 - 200
                        : sin((_animCtrl.value - 0.3) / 0.7 * pi * 6) * 20;
                    return Transform.translate(
                      offset: Offset(0, slam),
                      child: Text(
                        'K.O.!',
                        style: TextStyle(
                          fontSize: 72 - _animCtrl.value * 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: Colors.red.withValues(alpha: 0.8),
                              blurRadius: 20,
                            ),
                            Shadow(
                              color: Colors.orange.withValues(alpha: 0.5),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (_showKo) ...[
                const SizedBox(height: 20),
                const Text(
                  'VICTORY!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  winnerName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: winColor,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: winColor.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: ${widget.winnerScore.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0, end: 1),
                  builder: (_, val, __) => Opacity(
                    opacity: 1 - val,
                    child: Transform.scale(
                      scale: 1 + val * 2,
                      child: const Text('💥', style: TextStyle(fontSize: 100)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

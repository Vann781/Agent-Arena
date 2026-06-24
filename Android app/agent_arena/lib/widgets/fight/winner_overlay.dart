import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../services/sound_manager.dart';

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
  late Animation<double> _ballAnim;
  bool _showExplosion = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ballAnim = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    widget.soundManager.playVictory();
    _animCtrl.forward().then((_) => setState(() => _showExplosion = true));
    Future.delayed(const Duration(milliseconds: 1600), () {
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
    return Stack(
      children: [
        // Dark overlay
        AnimatedBuilder(
          animation: _animCtrl,
          builder: (_, child) => Container(
            color: Colors.black.withValues(alpha: 0.6 * _animCtrl.value),
          ),
        ),
        // Title
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                '${widget.winner.toUpperCase()} WINS!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${widget.winnerScore.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Ball throw animation
        if (!_showExplosion)
          AnimatedBuilder(
            animation: _ballAnim,
            builder: (_, __) => Positioned(
              left: _ballAnim.value < 0
                  ? MediaQuery.of(context).size.width / 2 + 40
                  : MediaQuery.of(context).size.width / 2 - 40,
              top:
                  MediaQuery.of(context).size.height / 2 -
                  100 -
                  (_ballAnim.value).abs() * 100,
              child: Transform.translate(
                offset: Offset(
                  _ballAnim.value * MediaQuery.of(context).size.width / 2,
                  0,
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),
        // Explosion
        if (_showExplosion)
          Center(
            child: TweenAnimationBuilder<double>(
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
          ),
      ],
    );
  }
}

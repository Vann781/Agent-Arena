import 'dart:math';
import 'package:flutter/material.dart';

enum FighterState { idle, attacking, hit, defeated, victory }

class FighterSprite extends StatefulWidget {
  final String agentId;
  final String spritePath;
  final FighterState state;
  final bool isLeft;
  final double healthPercent;

  const FighterSprite({
    super.key,
    required this.agentId,
    required this.spritePath,
    required this.state,
    required this.isLeft,
    required this.healthPercent,
  });

  @override
  State<FighterSprite> createState() => _FighterSpriteState();
}

class _FighterSpriteState extends State<FighterSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(FighterSprite old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _animCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, child) {
        double dx = 0, dy = 0, scale = 1, opacity = 1;
        double angle = 0;

        switch (widget.state) {
          case FighterState.attacking:
            dx = widget.isLeft ? 30 * _animCtrl.value : -30 * _animCtrl.value;
            angle = sin(_animCtrl.value * pi * 2) * 0.3;
            scale = 1 + sin(_animCtrl.value * pi * 4) * 0.1;
            break;
          case FighterState.hit:
            dx = (widget.isLeft ? -1 : 1) * 15 * sin(_animCtrl.value * pi * 4);
            scale = 1 - _animCtrl.value * 0.15;
            break;
          case FighterState.defeated:
            dy = 200 * _animCtrl.value;
            opacity = 1 - _animCtrl.value;
            angle = _animCtrl.value * (widget.isLeft ? -pi / 2 : pi / 2);
            break;
          case FighterState.victory:
            dy = -20 * sin(_animCtrl.value * pi * 2);
            scale = 1 + sin(_animCtrl.value * pi * 2) * 0.05;
            break;
          default:
            break;
        }

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(scale: scale, child: child!),
            ),
          ),
        );
      },
      child: _buildSprite(),
    );
  }

  Widget _buildSprite() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(widget.spritePath, height: 120, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(
          widget.agentId.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

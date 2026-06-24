import 'package:flutter/material.dart';

class HealthBar extends StatelessWidget {
  final double percent;
  final Color color;
  final Color darkColor;
  final String label;
  final bool rightAligned;

  const HealthBar({
    super.key,
    required this.percent,
    required this.color,
    required this.darkColor,
    required this.label,
    this.rightAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: rightAligned
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 160,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: Stack(
              children: [
                // Damage (lost health) background
                Positioned.fill(
                  child: Container(color: const Color(0xFF1A0000)),
                ),
                // Remaining health
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0, end: clamped),
                  builder: (_, value, __) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, darkColor],
                            begin: rightAligned
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            end: rightAligned
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Tick marks
                ...List.generate(10, (i) {
                  return Positioned(
                    left: i * 16.0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

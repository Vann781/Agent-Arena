import 'package:flutter/material.dart';

class HealthBar extends StatelessWidget {
  final double percent;
  final Color color;
  final String label;

  const HealthBar({
    super.key,
    required this.percent,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 1).toDouble();
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0, end: clamped),
            builder: (_, value, __) => Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

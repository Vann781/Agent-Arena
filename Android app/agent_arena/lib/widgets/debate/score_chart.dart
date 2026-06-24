import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/agent_names.dart';

class ScoreChart extends StatelessWidget {
  final Map<String, double> scores;

  const ScoreChart({super.key, required this.scores});

  Color _barColor(String agentId) {
    switch (agentId) {
      case 'pro':
      case 'agent_a':
        return AppColors.agentA;
      case 'con':
      case 'agent_b':
        return AppColors.agentB;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scores',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...scores.entries.map((entry) {
            final ratio = entry.value / maxScore;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayName(entry.key).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        entry.value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.rambahaur,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _barColor(entry.key),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

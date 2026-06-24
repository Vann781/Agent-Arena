import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/agent_names.dart';
import '../../models/history_model.dart';

class JudgeResultCard extends StatelessWidget {
  final JudgeResult result;

  const JudgeResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final winColor = result.winner == 'pro'
        ? AppColors.rambahaur
        : AppColors.shaamBahadur;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: winColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Judge\'s Verdict',
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              displayName(result.winner).toUpperCase(),
              style: TextStyle(
                color: winColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...result.scores.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName(entry.key).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              result.explanation,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          if (result.feedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Feedback',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...result.feedback.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${displayName(entry.key)}: ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

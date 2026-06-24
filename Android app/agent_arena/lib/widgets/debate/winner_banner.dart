import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/agent_names.dart';

class WinnerBanner extends StatelessWidget {
  final String winner;
  final String explanation;
  final VoidCallback? onViewDetails;

  const WinnerBanner({
    super.key,
    required this.winner,
    required this.explanation,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final winColor = winner == 'pro'
        ? AppColors.rambahaur
        : AppColors.shaamBahadur;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: winColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: AppColors.amber),
          const SizedBox(height: 12),
          const Text(
            'Winner!',
            style: TextStyle(
              color: AppColors.amber,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName(winner).toUpperCase(),
            style: TextStyle(
              color: winColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (onViewDetails != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.visibility, color: AppColors.cyan),
              label: const Text(
                'View Full Results',
                style: TextStyle(color: AppColors.cyan),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

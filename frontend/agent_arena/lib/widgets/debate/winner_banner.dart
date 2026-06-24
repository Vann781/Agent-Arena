import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.amber.withValues(alpha: 0.15),
            AppColors.amber.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            winner.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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

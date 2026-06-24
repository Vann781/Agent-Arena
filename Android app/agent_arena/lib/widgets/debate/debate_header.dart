import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class DebateHeader extends StatelessWidget {
  final String topic;
  final int currentRound;
  final int maxRounds;
  final String phase;
  final List<String> agents;

  const DebateHeader({
    super.key,
    required this.topic,
    required this.currentRound,
    required this.maxRounds,
    required this.phase,
    required this.agents,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentRound / maxRounds;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: const [
            Color(0xFF1A1A3E),
            Color(0xFF0D0D1A),
            Color(0xFF05050D),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStat('Round', '$currentRound/$maxRounds'),
              const SizedBox(width: 16),
              _buildStat('Phase', phase.toUpperCase()),
              const Spacer(),
              Text(
                '${agents.length} agents',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.rambahaur,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

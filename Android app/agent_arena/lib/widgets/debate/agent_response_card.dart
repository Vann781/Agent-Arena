import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class AgentResponseCard extends StatelessWidget {
  final String agentId;
  final String side;
  final String response;
  final bool isLatest;

  const AgentResponseCard({
    super.key,
    required this.agentId,
    required this.side,
    required this.response,
    this.isLatest = false,
  });

  Color get _agentColor {
    switch (agentId) {
      case 'agent_a':
      case 'optimist':
        return AppColors.agentA;
      case 'agent_b':
      case 'pessimist':
        return AppColors.agentB;
      case 'engineer':
        return AppColors.agentEngineer;
      case 'economist':
        return AppColors.agentEconomist;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _agentColor.withValues(alpha: 0.08),
            _agentColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest
              ? _agentColor.withValues(alpha: 0.5)
              : AppColors.glassBorder,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _agentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    agentId.isNotEmpty ? agentId[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: _agentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agentId.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _agentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      side,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(color: AppColors.cyan, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

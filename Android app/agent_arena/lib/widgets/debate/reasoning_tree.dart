import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class ReasoningTree extends StatelessWidget {
  final List<String> reasoningPath;

  const ReasoningTree({super.key, required this.reasoningPath});

  @override
  Widget build(BuildContext context) {
    if (reasoningPath.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, size: 16, color: AppColors.rambahaur),
              const SizedBox(width: 6),
              const Text(
                'Reasoning Path',
                style: TextStyle(
                  color: AppColors.rambahaur,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reasoningPath.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: EdgeInsets.only(left: (i * 16).toDouble()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}.',
                    style: TextStyle(
                      color: AppColors.rambahaur.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
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

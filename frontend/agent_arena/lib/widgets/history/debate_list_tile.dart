import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/history_model.dart';

class DebateListTile extends StatelessWidget {
  final DebateSummary debate;
  final VoidCallback onTap;

  const DebateListTile({super.key, required this.debate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debate.topic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (debate.winner != null) ...[
                            Text(
                              debate.winner!.replaceAll('_', ' '),
                              style: const TextStyle(
                                color: AppColors.cyan,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 10,
                              color: AppColors.glassBorder,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${debate.totalVotes} votes',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            Formatters.formatShortDate(debate.createdAt),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (debate.status) {
      case 'active':
        return AppColors.green;
      case 'completed':
        return AppColors.cyan;
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _statusIcon {
    switch (debate.status) {
      case 'active':
        return Icons.record_voice_over;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.hourglass_empty;
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class HistoryFilterBar extends StatelessWidget {
  final String? currentFilter;
  final void Function(String?) onFilterChanged;

  const HistoryFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Active', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = currentFilter == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.rambahaur.withValues(alpha: 0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.rambahaur.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.rambahaur : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

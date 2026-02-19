import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class DraggableLabel extends StatelessWidget {
  final String label;
  final String data;

  const DraggableLabel({super.key, required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: data,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildChip(),
      ),
      child: _buildChip(),
    );
  }

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }
}

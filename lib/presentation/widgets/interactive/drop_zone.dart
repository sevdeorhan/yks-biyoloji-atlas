import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class DropZone extends StatefulWidget {
  final String label;
  final Function(String data)? onAccept;

  const DropZone({super.key, required this.label, this.onAccept});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovered = true);
        return true;
      },
      onLeave: (_) => setState(() => _isHovered = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onAccept?.call(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.dropZoneHover : AppColors.dropZoneActive,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.border,
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

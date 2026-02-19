import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GlowingRegion extends StatefulWidget {
  final Widget child;
  final bool glowing;

  const GlowingRegion({super.key, required this.child, this.glowing = true});

  @override
  State<GlowingRegion> createState() => _GlowingRegionState();
}

class _GlowingRegionState extends State<GlowingRegion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.glowing) return widget.child;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.glowColor.withOpacity(_animation.value),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

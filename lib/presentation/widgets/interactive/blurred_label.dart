import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredLabel extends StatefulWidget {
  final String label;
  final bool revealed;

  const BlurredLabel({super.key, required this.label, this.revealed = false});

  @override
  State<BlurredLabel> createState() => _BlurredLabelState();
}

class _BlurredLabelState extends State<BlurredLabel> {
  late bool _revealed;

  @override
  void initState() {
    super.initState();
    _revealed = widget.revealed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _revealed
            ? Text(widget.label, key: const ValueKey('revealed'))
            : ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Text(widget.label, key: const ValueKey('blurred')),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SideArrows extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool visible;

  const SideArrows({
    super.key,
    required this.onLeft,
    required this.onRight,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.fast_rewind, size: 48, color: Colors.white70),
            onPressed: visible ? onLeft : null,
          ),
          IconButton(
            icon: const Icon(Icons.fast_forward, size: 48, color: Colors.white70),
            onPressed: visible ? onRight : null,
          ),
        ],
      ),
    );
  }
}

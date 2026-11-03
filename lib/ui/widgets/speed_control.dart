import 'package:flutter/material.dart';

class SpeedControl extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedControl({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: currentSpeed,
      onSelected: onSpeedChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0.5, child: Text('0.5x')),
        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
        const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${currentSpeed}x',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

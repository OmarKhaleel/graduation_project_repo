import 'package:flutter/material.dart';

class CustomScaleTransition extends StatelessWidget {
  final Animation<double> animation;

  const CustomScaleTransition({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: 250, // Increase width for wider pulsating range
        height: 200, // Increase height for wider pulsating range
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2), // White color with transparency
        ),
      ),
    );
  }
}

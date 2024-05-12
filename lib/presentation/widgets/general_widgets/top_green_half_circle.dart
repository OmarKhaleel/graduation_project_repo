import 'package:flutter/material.dart';

class TopGreenHalfCircle extends StatelessWidget {
  const TopGreenHalfCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -MediaQuery.of(context).size.width * 1.1,
      left: -MediaQuery.of(context).size.width * 0.5,
      child: Container(
        width: MediaQuery.of(context).size.width * 2,
        height: MediaQuery.of(context).size.width * 1.5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF00916E),
        ),
      ),
    );
  }
}

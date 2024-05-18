import 'package:flutter/material.dart';

class RingContainer extends StatelessWidget {
  final bool isListening;
  final Widget child;

  const RingContainer(
      {super.key, required this.isListening, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // width of the outer circle
      height: 200, // height of the outer circle
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isListening
              ? Colors.transparent
              : const Color(0xFF24BF86), // Hide ring when listening
          width: 10, // width of the ring
        ),
      ),
      child: child,
    );
  }
}

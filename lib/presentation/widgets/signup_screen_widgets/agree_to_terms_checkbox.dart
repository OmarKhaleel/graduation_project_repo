import 'package:flutter/material.dart';

class AgreeToTermsCheckbox extends StatelessWidget {
  final bool agreeToTerms;
  final Function(bool?) onChanged;

  const AgreeToTermsCheckbox(
      {super.key, required this.agreeToTerms, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: agreeToTerms,
          onChanged: onChanged,
        ),
        GestureDetector(
          onTap: () {
            // Include Privacy Policy and Terms & Conditions here
          },
          child: const Text(
            'I agree to the Privacy policy and Terms & conditions',
            style: TextStyle(
              color: Color(0xFF00916E),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

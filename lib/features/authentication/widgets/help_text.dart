import 'package:flutter/material.dart';
import '../../../shared/extentions/context_extention.dart';

class HelpText extends StatelessWidget {
  final String text;

  const HelpText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
      textAlign: TextAlign.center,
    );
  }
}

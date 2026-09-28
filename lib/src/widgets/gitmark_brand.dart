import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

class GitmarkBrand extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // Icon, SizedBox y Text componen el Brand de GitMark
        Icon(Icons.terminal, color: AppTheme.acentoCyan),
        SizedBox(width: 8),
        Text(
          'GitMark',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textoPrincipal,
          ),
        ),
      ],
    );
  }
}

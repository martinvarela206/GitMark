import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

// Este widget es el avatar para el repositorio.

class RepoAvatar extends StatelessWidget {
  const RepoAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.fondoAvatar,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(
        Icons.code, 
        color: AppTheme.acentoCyan, 
        size: 22,
      ),
    );
  }
}
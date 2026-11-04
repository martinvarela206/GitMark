import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

// Este widget es el avatar para el repositorio.

class RepoAvatar extends StatelessWidget {
  final String? avatarUrl;

  const RepoAvatar({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.fondoAvatar,
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      // Si hay url, intenta mostrar el icono, sino muestra un icono por defecto.
      // El condicional se usa cuando no hay url.
      child: (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.code,
                color: AppTheme.acentoCyan,
                size: 22,
              ),
            )
          : const Icon(
              Icons.code,
              color: AppTheme.acentoCyan,
              size: 22,
            ),
    );
  }
}
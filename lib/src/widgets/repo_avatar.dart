import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Contenedor de avatar para el dueño u organización del repositorio.
/// 
/// Resiliencia y manejo de errores de red:
/// 1. Si 'avatarUrl' es nulo o vacío, muestra directamente el icono de código en cyan.
/// 2. Si hay URL, intenta cargar la imagen con Image.network().
/// 3. Si la conexión a internet falla o la imagen no existe (error 404), 'errorBuilder'
///    captura la excepción y dibuja el icono por defecto en vez de romper la pantalla.
/// 4. 'clipBehavior: Clip.antiAlias' asegura que los bordes redondeados recorten la imagen suavemente.
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

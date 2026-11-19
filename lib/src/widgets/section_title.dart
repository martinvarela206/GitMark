import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Título estandarizado para separar secciones visuales en la aplicación.
/// 
/// ¿Por qué modularizarlo en vez de escribir un Text con Padding repetido?
/// Para asegurar que todas las secciones ('Repositorios recomendados', 'Recientes', etc.)
/// tengan exactamente la misma tipografía, espaciado exterior (padding) y color institucional,
/// facilitando cambios globales de diseño en una sola línea.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

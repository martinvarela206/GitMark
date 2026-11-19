import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Componente que dibuja las métricas del repositorio (estrellas y lenguaje de programación).
/// 
/// Características pedagógicas:
/// 1. Formateador numérico (_formatStars): Si un repositorio tiene más de 1.000 estrellas
///    (ej. 38.400), lo formatea amigablemente como "38.4k" para ahorrar espacio en la tarjeta.
/// 2. Semántica de color (_getLanguageColor): Asigna un punto de color característico a cada
///    tecnología (azul para Dart, ámbar para JavaScript, verde para Python, cyan para Markdown).
class RepoInfo extends StatelessWidget {
  final int starsCount;
  final String language;

  const RepoInfo({
    super.key,
    required this.starsCount,
    required this.language,
  });

  /// Formatea números grandes para hacerlos legibles (ej: 38400 -> 38.4k)
  String _formatStars(int stars) {
    if (stars >= 1000) {
      return '${(stars / 1000).toStringAsFixed(1)}k';
    }
    return stars.toString();
  }

  /// Asigna un color representativo al lenguaje de programación
  Color _getLanguageColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'dart':
        return Colors.blue;
      case 'javascript':
        return Colors.amber;
      case 'python':
        return Colors.green;
      case 'markdown':
        return AppTheme.acentoCyan;
      default:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: AppTheme.acentoEstrellas,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          _formatStars(starsCount),
          style: const TextStyle(
            color: AppTheme.textoSecundario,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getLanguageColor(language),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          language,
          style: const TextStyle(
            color: AppTheme.textoSecundario,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

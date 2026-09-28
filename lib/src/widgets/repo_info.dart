import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

class RepoInfo extends StatelessWidget {
  final int starsCount;
  final String language;

  const RepoInfo({ // Este widget recibe 2 argumentos, cantidad de estrellas y lenguaje
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

        const Icon( // Icono de la estrella
          Icons.star_rounded,
          color: AppTheme.acentoEstrellas,
          size: 16,
        ),
        
        const SizedBox(width: 4), // gap horizontal
        
        Text( // cantidad de estrellas
          _formatStars(starsCount),
          style: const TextStyle(
            color: AppTheme.textoSecundario,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 16), // gap horizontal
        
        Container( // Icono del lenguaje
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getLanguageColor(language),
            shape: BoxShape.circle,
          ),
        ),
        
        const SizedBox(width: 6), // gap horizontal
        
        Text( // Lenguaje del repo
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
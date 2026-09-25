import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RepoCard extends StatelessWidget {
  final String fullName;
  final String description;
  final int starsCount;
  final String language;
  final VoidCallback? onTap;

  const RepoCard({
    super.key,
    required this.fullName,
    required this.description,
    required this.starsCount,
    required this.language,
    this.onTap,
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
    return Card(
      elevation: 0,
      color: AppTheme.fondoTarjeta,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppTheme.bordeSutil, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar o icono de repositorio
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.fondoAvatar,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.code, color: AppTheme.acentoCyan, size: 22),
              ),
              const SizedBox(width: 14),

              // Contenido textual con prevención activa de overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: AppTheme.textoPrincipal,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppTheme.textoSecundario,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Metadatos: Estrellas ⭐ y Lenguaje
                    Row(
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
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppTheme.iconoMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
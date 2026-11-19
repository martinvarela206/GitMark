import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Componente que renderiza el título del repositorio y su descripción.
/// 
/// Prevención del desbordamiento visual (Anti-Overflow):
/// En dispositivos con pantallas angostas, los títulos y descripciones extensas
/// pueden provocar el clásico error de franjas amarillas y negras de Flutter ('RenderFlex overflowed').
/// Para prevenirlo, este widget aplica:
/// - maxLines: 1 en el título y maxLines: 2 en la descripción.
/// - TextOverflow.ellipsis: coloca automáticamente puntos suspensivos ("...") si el texto excede el espacio.
class RepoDescription extends StatelessWidget {
  final String fullName;
  final String description;

  const RepoDescription({
    super.key,
    required this.fullName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}

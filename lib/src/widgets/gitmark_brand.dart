import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Identidad de marca (Branding) visible en el AppBar de la aplicación.
/// 
/// Modularizar el logo y título en un widget independiente garantiza consistencia:
/// si se decide rediseñar la marca, el cambio se refleja en todas las pantallas
/// que incluyan GitmarkBrand sin modificar el AppBar de cada una.
class GitmarkBrand extends StatelessWidget {
  const GitmarkBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
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

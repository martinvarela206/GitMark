import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Este widget es básicamente es un Text("Repositorios recomendados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// pero ademas aplica padding para separarlo de otros widgets y utiliza 
// theme para obtener la fuente y el tamaño del texto, haciendolo reutilizable.

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textoPrincipal, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
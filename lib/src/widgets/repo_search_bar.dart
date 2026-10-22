import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Este widget es la barra de busqueda de los repositorios.

class RepoSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const RepoSearchBar({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.fondoTarjeta,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppTheme.bordeSutil),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.textoPrincipal, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar repositorio (owner/repo)...',
          hintStyle: const TextStyle(color: AppTheme.textoSecundario, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textoSecundario, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
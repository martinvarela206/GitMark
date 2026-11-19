import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra de búsqueda de repositorios estilizada en formato píldora.
/// 
/// Características:
/// 1. 'TextField' desacoplado: Expone el callback 'onChanged' para que la pantalla que lo use
///    pueda filtrar la lista en vivo sin que la barra de búsqueda conozca la lista de datos.
/// 2. 'border: InputBorder.none': Elimina la línea inferior por defecto de Material para
///    mantener una estética limpia dentro del contenedor con bordes redondeados (borderRadius: 24).
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
        decoration: const InputDecoration(
          hintText: 'Buscar repositorio (owner/repo)...',
          hintStyle: TextStyle(color: AppTheme.textoSecundario, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: AppTheme.textoSecundario, size: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

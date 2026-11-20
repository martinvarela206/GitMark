import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra de pestañas horizontal ubicada en la parte inferior del AppBar de HomePage.
/// 
/// ¿Por qué implementa 'PreferredSizeWidget' y sobreescribe 'preferredSize'?
/// A diferencia de los widgets normales que se adaptan libremente a su contenido,
/// el AppBar necesita calcular la altura física fija de su encabezado antes de dibujarlo.
/// Dado que TabBarApp se ubica en la propiedad 'bottom' del AppBar, está obligada por
/// contrato a declarar cuántos píxeles de alto va a ocupar (en este caso, 48.0 px).
/// 
/// Evolución de arquitectura:
/// - Se añade el callback 'onTap' para notificar a HomePage el cambio de pestaña activa
///   y permitir el filtrado reactivo de repositorios en memoria o consulta a SQLite.
class TabBarApp extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<int>? onTap;

  const TabBarApp({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      indicatorColor: AppTheme.acentoCyan,
      labelColor: AppTheme.acentoCyan,
      unselectedLabelColor: AppTheme.textoSecundario,
      onTap: onTap,
      tabs: const [
        Tab(text: 'Todos'),
        Tab(text: 'Recientes'),
        Tab(text: 'Públicos'),
        Tab(text: 'Mis repos'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

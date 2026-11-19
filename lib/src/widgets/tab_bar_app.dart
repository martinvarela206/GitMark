import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra de pestañas horizontal ubicada en la parte inferior del AppBar de HomePage.
/// 
/// ¿Por qué implementa 'PreferredSizeWidget' y sobreescribe 'preferredSize'?
/// A diferencia de los widgets normales que se adaptan libremente a su contenido,
/// el AppBar necesita calcular la altura física fija de su encabezado antes de dibujarlo.
/// Dado que TabBarApp se ubica en la propiedad 'bottom' del AppBar, está obligada por
/// contrato a declarar cuántos píxeles de alto va a ocupar (en este caso, 48.0 px).
class TabBarApp extends StatelessWidget implements PreferredSizeWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      isScrollable: true,
      indicatorColor: AppTheme.acentoCyan,
      labelColor: AppTheme.acentoCyan,
      unselectedLabelColor: AppTheme.textoSecundario,
      tabs: [
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

import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

// Esta es la barra superior con las pestañas. Este es usado en home_page.dart.

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

  // A diferencia de otros widget que se estiran o 
  // encogen según su contenido o espacio disponible, 
  // AppBar necesita saber cuantos pixeles va a medir. 
  // Dado que el TabBar va en el Bottom de la AppBar, 
  // entonces tiene que decirle a esta cuanto espacio 
  // ocupa en el Bottom.
  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}
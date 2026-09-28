import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

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

  // Altura requerida por AppBar para saber cuánto espacio reservar
  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}
import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';
import 'package:gitmark/src/widgets/cuota_api_info.dart';
import 'package:gitmark/src/widgets/drawer_app.dart';
import 'package:gitmark/src/widgets/gitmark_brand.dart';
import 'package:gitmark/src/widgets/repo_card.dart';
import 'package:gitmark/src/widgets/tab_bar_app.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // Gestor automatico de pestaña, sincroniza el TabBar (pestañas) con el TabBarView (contenido para cada pestaña)
      length: 4, // 4 pestañas: Todos, Recientes, Públicos, Mis repos
      child: Scaffold(
        backgroundColor: AppTheme.fondoPrincipal,
        appBar: AppBar(
          backgroundColor: AppTheme.fondoTarjeta,
          elevation: 0,

          title: const GitmarkBrand(), // superior izquierda
          
          actions: [ // superior derecha
            CuotaApiInfo(),
          ],

          bottom: const TabBarApp(), // Pestañas
        ),
        body: Center(
          child: RepoCard(
            fullName: 'LeCoupa/awesome-cheatsheets',
            description: 'Colección curada de cheatsheets para desarrolladores móviles, frontend y backend.',
            starsCount: 38400,
            language: 'Markdown',
            onTap: () {},
          ),
        ),
        drawer: DrawerApp(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';
import 'package:gitmark/src/widgets/cuota_api_info.dart';
import 'package:gitmark/src/widgets/drawer_app.dart';
import 'package:gitmark/src/widgets/gitmark_brand.dart';
import 'package:gitmark/src/widgets/recent_repo_banner.dart';
import 'package:gitmark/src/widgets/repo_card.dart';
import 'package:gitmark/src/widgets/repo_search_bar.dart';
import 'package:gitmark/src/widgets/section_title.dart';
import 'package:gitmark/src/widgets/tab_bar_app.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static List<Widget> _temporalListRepoCards() {
    return const [
      RepoCard(
        fullName: 'LeCoupa/awesome-cheatsheets',
        description: 'Colección curada de cheatsheets para desarrolladores móviles, frontend y backend.',
        starsCount: 38400,
        language: 'Markdown',
      ),
      RepoCard(
        fullName: 'flutter/flutter',
        description: 'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.',
        starsCount: 165000,
        language: 'Dart',
      ),
      RepoCard(
        fullName: 'flutter-community/flutter-markdown-guide',
        description: 'Guía paso a paso interactiva para renderizar documentación Markdown en Flutter.',
        starsCount: 1520,
        language: 'Dart',
      ),
      RepoCard(
        fullName: 'martinvarela206/GitMark',
        description: 'Cliente móvil y web para exploración y lectura optimizada de Markdown en GitHub.',
        starsCount: 42,
        language: 'Dart',
      ),
      RepoCard(
        fullName: 'sindresorhus/awesome',
        description: 'Listas curadas sobre todo tipo de temas interesantes en programación y desarrollo.',
        starsCount: 310000,
        language: 'Markdown',
      ),
      RepoCard(
        fullName: 'vinta/awesome-python',
        description: 'Colección de frameworks, librerías y recursos indispensables del ecosistema Python.',
        starsCount: 220000,
        language: 'Python',
      ),
    ];
  }

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
        body: Column(
          children: [
            const RepoSearchBar(),
            const RecentRepoBanner(),
            const SectionTitle(title: 'Repositorios recomendados'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom:24),
                children: _temporalListRepoCards()
              )
            )
          ],
        ),
        drawer: DrawerApp(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cuota_api_info.dart';
import '../widgets/drawer_app.dart';
import '../widgets/gitmark_brand.dart';
import '../widgets/recent_repo_banner.dart';
import '../widgets/repo_card.dart';
import '../widgets/repo_search_bar.dart';
import '../widgets/section_title.dart';
import '../widgets/tab_bar_app.dart';
import 'repo_explorer_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Construye la lista de repositorios leyendo el JSON asíncronamente
  Widget _buildRepoList(BuildContext context, bool isDesktop) {
    return FutureBuilder<List<RepositoryModel>>(
      future: LocalDataService.loadRepositories(),
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<RepositoryModel>> snapshot) {
        // 1. Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.acentoCyan),
          );
        } 
        // 2. Estado de error
        else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar datos: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. Datos listos: mapeamos cada RepositoryModel a un widget RepoCard
        final repos = snapshot.data ?? [];
        final repoWidgets = repos.map((repo) {
          return RepoCard(
            repository: repo,
            // Al hacer tap, abrimos la pantalla del explorador pasando el repo seleccionado
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RepoExplorerPage(repository: repo),
                ),
              );
            },
          );
        }).toList();

        // Muestra en GridView (si es pantalla ancha) o ListView vertical
        return isDesktop
            ? GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.6,
                padding: const EdgeInsets.only(bottom: 24),
                children: repoWidgets,
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: repoWidgets,
              );
      },
    );
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
          actions: const [
            CuotaApiInfo(), // superior derecha
          ],
          bottom: const TabBarApp(), // Pestañas
        ),
        body: Column(
          children: [
            const RepoSearchBar(),
            const RecentRepoBanner(),
            const SectionTitle(title: 'Repositorios recomendados'),
            Expanded(
              // Inyectamos la lista dinámica construida por el FutureBuilder
              child: _buildRepoList(context, false),
            ),
          ],
        ),
        drawer: const DrawerApp(),
      ),
    );
  }
}
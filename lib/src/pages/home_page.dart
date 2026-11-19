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

/// Pantalla principal de la aplicación.
/// 
/// ¿Por qué es un StatefulWidget?
/// Porque su contenido cambia dinámicamente cuando se cargan los repositorios,
/// se agregan más elementos al hacer scroll hacia abajo, o se alternan estados
/// de carga (spinners) que requieren redibujar la interfaz con setState().
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  /// Colección en memoria de los repositorios que se están mostrando en pantalla.
  final List<RepositoryModel> _repos = [];

  /// Banderas booleanas para evitar que si el usuario scrollea rápido se
  /// disparen múltiples peticiones repetidas a la vez.
  /// - _isLoading: La primera vez, al no haber repositorios, muestra un spinner
  /// en el lugar de la lista de repositorios.
  bool _isLoading = false;
  /// - _isLoadingMore: Debajo de la lista de los repositorios que ya se cargaron
  /// se muestra otro spinner para indicar que se están cargando mas.
  bool _isLoadingMore = false;

  /// Control de paginación para la API:
  /// - Actualmente: Simula el avance de páginas (1, 2, 3...) y se reinicia a 1 en el refresco.
  /// - A futuro: Se le pasará como parámetro a la API real de GitHub (?page=$_paginaActual)
  ///   para solicitar lotes de repositorios de a 10 o 30 por llamada en vez de todos juntos.
  // ignore: unused_field
  int _paginaActual = 1;

  @override
  void initState() {
    super.initState();
    // 1. Carga inicial: apenas se construye la pantalla, busca los primeros repositorios.
    _cargarRepositoriosIniciales();

    // 2. Listener de Scroll Infinito:
    // Escucha cada movimiento del scroll. La fórmula detecta si el usuario está a 200 píxeles
    // o menos de llegar al fondo de la lista:
    // - pixels: Posición actual del scroll.
    // - maxScrollExtent: El final absoluto de la lista.
    // - Restar 200px permite pedir los nuevos datos ANTES de que el usuario llegue al final,
    //   logrando una experiencia fluida sin pausas visibles.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          !_isLoading) {
        _cargarMasRepositorios();
      }
    });
  }

  @override
  void dispose() {
    // Es muy importante destruir el ScrollController al salir de la pantalla, 
    // sino queda escuchando en segundo plano y consumiendo memoria.
    _scrollController.dispose();
    super.dispose();
  }

  /// Carga inicial: limpia la lista y solicita los repositorios por primera vez.
  /// QUE REPOSITORIOS SOLICITA POR PRIMERA VEZ?
  Future<void> _cargarRepositoriosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final nuevos = await LocalDataService.loadRepositories();
      setState(() {
        _repos.clear();
        _repos.addAll(nuevos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Carga adicional disparada automáticamente por el scroll infinito.
  Future<void> _cargarMasRepositorios() async {
    setState(() => _isLoadingMore = true);
    
    // Simula una demora de red (1.5 segundos) para que sea visible el spinner inferior.
    await Future.delayed(const Duration(milliseconds: 1500));
    final masRepos = await LocalDataService.loadRepositories();
    
    setState(() {
      _paginaActual++; // Incrementa la página para la siguiente tanda.
      _repos.addAll(masRepos);
      _isLoadingMore = false;
    });
  }

  /// Navega al explorador de archivos pasando el repositorio seleccionado como parámetro.
  void _navegarAExplorador(BuildContext context, RepositoryModel repo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepoExplorerPage(repository: repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 pestañas superiores: Todos, Recientes, Públicos, Mis repos
      child: Scaffold(
        backgroundColor: AppTheme.fondoPrincipal,
        appBar: AppBar(
          backgroundColor: AppTheme.fondoTarjeta,
          elevation: 0,
          title: const GitmarkBrand(),
          actions: const [
            CuotaApiInfo(),
          ],
          bottom: const TabBarApp(),
        ),
        drawer: const DrawerApp(),
        body: Column(
          children: [
            const RepoSearchBar(),
            const RecentRepoBanner(),
            const SectionTitle(title: 'Repositorios recomendados'),
            Expanded(
              // Si la pantalla está cargando por primera vez, mostramos el spinner central
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.acentoCyan),
                    )
                  // RefreshIndicator: permite el gesto "Pull-to-Refresh" (arrastrar hacia abajo)
                  // para refrescar los datos, reiniciando la página a 1.
                  : RefreshIndicator(
                      color: AppTheme.acentoCyan,
                      backgroundColor: AppTheme.fondoTarjeta,
                      onRefresh: () async {
                        _paginaActual = 1;
                        await _cargarRepositoriosIniciales();
                      },
                      // ListView.builder: Construye en memoria únicamente las tarjetas visibles,
                      // ahorrando memoria y batería del dispositivo.
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        // TRUCO DE LA CÁTEDRA: itemCount suma +1 si estamos cargando más elementos.
                        // Ese elemento extra es el casillero reservado para el spinner del fondo.
                        itemCount: _repos.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Si el índice coincide con el largo de la lista, significa que
                          // llegamos al casillero extra: dibujamos el spinner de carga inferior.
                          if (index == _repos.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(color: AppTheme.acentoCyan),
                              ),
                            );
                          }

                          // Si no es el casillero extra, dibuja la tarjeta normal del repositorio.
                          final repo = _repos[index];
                          return RepoCard(
                            repository: repo,
                            onTap: () => _navegarAExplorador(context, repo),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/repository_model.dart';
import '../services/database_service.dart';
import '../services/github_service.dart';
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

  /// Colección de repositorios visitados recuperados de SQLite para la pestaña Recientes.
  List<RepositoryModel> _reposRecientes = [];

  /// Último repositorio visitado recuperado de SQLite para el banner superior.
  RepositoryModel? _ultimoRepo;

  /// Índice de la pestaña actualmente activa (0: Todos, 1: Recientes, 2: Públicos, 3: Mis repos).
  int _tabSeleccionada = 0;

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
    // 1. Carga inicial: recupera último visitado, recientes y catálogo general.
    _inicializarDatos();

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
          !_isLoading &&
          _tabSeleccionada == 0) {
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

  /// Carga inicial: inicializa la base de datos, recupera el último visitado
  /// y carga los repositorios del catálogo.
  Future<void> _inicializarDatos() async {
    setState(() => _isLoading = true);
    try {
      // 1. Detección de primer arranque: ¿SQLite está vacía?
      final tieneRegistros = await DatabaseService.instance.hasRepositories();
      if (!tieneRegistros) {
        try {
          final repoGitMark = await GitHubService.instance.getRepository('martinvarela206', 'GitMark');
          await DatabaseService.instance.insertOrUpdate(repoGitMark);
        } catch (_) {}
      }

      // 2. Cargamos el historial de recientes y el último visitado desde SQLite
      await _actualizarDatosDesdeSQLite();

      // 3. Cargamos los repositorios del catálogo general
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

  /// Consulta SQLite para refrescar el banner y la lista de recientes
  Future<void> _actualizarDatosDesdeSQLite() async {
    final ultimo = await DatabaseService.instance.getLastVisitedRepo();
    final recientes = await DatabaseService.instance.getRecentRepositories();
    if (mounted) {
      setState(() {
        _ultimoRepo = ultimo;
        _reposRecientes = recientes;
      });
    }
  }

  /// Carga adicional disparada automáticamente por el scroll infinito.
  Future<void> _cargarMasRepositorios() async {
    setState(() => _isLoadingMore = true);
    // Simula una demora de red (1 segundo) para que sea visible el spinner inferior.
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final masRepos = await LocalDataService.loadRepositories();
      setState(() {
        _paginaActual++; // Incrementa la página para la siguiente tanda.
        _repos.addAll(masRepos);
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  /// Navega al explorador de archivos pasando el repositorio seleccionado como parámetro
  /// y guarda la visita en SQLite.
  Future<void> _navegarAExplorador(BuildContext context, RepositoryModel repo) async {
    // 1. Guardamos la visita en SQLite con la fecha/hora actual
    await DatabaseService.instance.insertOrUpdate(repo);

    // 2. Refrescamos el banner superior y la lista de recientes de inmediato
    await _actualizarDatosDesdeSQLite();

    // 3. Navegamos a la pantalla de exploración
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepoExplorerPage(repository: repo),
      ),
    );

    // Al regresar del explorador, volvemos a sincronizar la vista
    _actualizarDatosDesdeSQLite();
  }

  /// Filtra la lista a mostrar según la pestaña seleccionada
  List<RepositoryModel> get _reposFiltrados {
    switch (_tabSeleccionada) {
      case 1:
        return _reposRecientes;
      case 2:
        return _repos.where((r) => !r.isPrivate).toList();
      case 3:
        return _repos.where((r) => r.repoCategory == 'mine').toList();
      case 0:
      default:
        return _repos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaActual = _reposFiltrados;

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
          bottom: TabBarApp(
            onTap: (index) {
              setState(() => _tabSeleccionada = index);
              if (index == 1) {
                _actualizarDatosDesdeSQLite();
              }
            },
          ),
        ),
        drawer: const DrawerApp(),
        body: Column(
          children: [
            const RepoSearchBar(),
            // Banner superior dinámico con el último repositorio visitado
            RecentRepoBanner(
              repoName: _ultimoRepo?.fullName ?? 'Sin visitas recientes',
              onOpen: _ultimoRepo != null
                  ? () => _navegarAExplorador(context, _ultimoRepo!)
                  : null,
            ),
            SectionTitle(
              title: _tabSeleccionada == 1
                  ? 'Historial de visitas recientes (SQLite)'
                  : (_tabSeleccionada == 2
                      ? 'Repositorios públicos'
                      : (_tabSeleccionada == 3
                          ? 'Mis repositorios'
                          : 'Repositorios recomendados')),
            ),
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
                        await _inicializarDatos();
                      },
                      child: _tabSeleccionada == 1 && listaActual.isEmpty
                          ? _buildEmptyRecientes()
                          // ListView.builder: Construye en memoria únicamente las tarjetas visibles,
                          // ahorrando memoria y batería del dispositivo.
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              // TRUCO DE LA CÁTEDRA: itemCount suma +1 si estamos cargando más elementos.
                              // Ese elemento extra es el casillero reservado para el spinner del fondo.
                              itemCount: listaActual.length +
                                  (_isLoadingMore && _tabSeleccionada == 0 ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Si el índice coincide con el largo de la lista, significa que
                                // llegamos al casillero extra: dibujamos el spinner de carga inferior.
                                if (index == listaActual.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.acentoCyan,
                                      ),
                                    ),
                                  );
                                }

                                // Si no es el casillero extra, dibuja la tarjeta normal del repositorio.
                                final repo = listaActual[index];
                                return RepoCard(
                                  repository: repo,
                                  onTap: () => _navegarAExplorador(context, repo),
                                  onSyncCompleted: _actualizarDatosDesdeSQLite,
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

  /// Estado vacío educativo para la pestaña Recientes
  Widget _buildEmptyRecientes() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 60),
        Icon(Icons.history_toggle_off, size: 64, color: AppTheme.iconoMuted),
        SizedBox(height: 16),
        Text(
          'No tienes repositorios recientes',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textoPrincipal,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Explora cualquier repositorio desde la pestaña "Todos" o sincronízalo para que aparezca aquí disponible sin conexión.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textoSecundario, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

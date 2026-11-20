import 'package:flutter/material.dart';
import '../models/git_file_model.dart';
import '../models/repository_model.dart';
import '../services/database_service.dart';
import '../services/github_service.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import 'document_view_page.dart';

/// Explorador interactivo de archivos y directorios del repositorio.
/// 
/// ¿Por qué evoluciona a un StatefulWidget?
/// Porque la navegación profunda por carpetas requiere gestionar un estado interno mutable:
/// - _currentPath: La subcarpeta actual donde está parado el usuario.
/// - _pathHistory: Una pila (stack) de historial para recordar de qué carpetas venimos y retroceder.
/// - _isLoading y _files: El estado reactivo de carga y los archivos recuperados en vivo.
class RepoExplorerPage extends StatefulWidget {
  /// Recibe el repositorio seleccionado desde HomePage mediante inyección en el constructor.
  final RepositoryModel repository;

  const RepoExplorerPage({super.key, required this.repository});

  @override
  State<RepoExplorerPage> createState() => _RepoExplorerPageState();
}

class _RepoExplorerPageState extends State<RepoExplorerPage> {
  String _currentPath = '';
  final List<String> _pathHistory = [];
  bool _isLoading = false;
  bool _isFromCache = false;
  String? _errorMessage;
  List<GitFileModel> _files = [];

  /// Determina si el repositorio proviene de la API pública de GitHub o de los mockups locales
  bool get _isRemote => widget.repository.htmlUrl.contains('github.com');

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
  }

  /// Consulta los archivos: primero desde SQLite (Cache-First) para ahorrar cuota,
  /// o desde GitHub API si es remoto y no estaba cacheado (o forceRefresh).
  Future<void> _cargarContenidos({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<GitFileModel> result = [];

      if (_isRemote) {
        // 1. Intentamos leer desde la caché local de SQLite si no se forzó refresco
        if (!forceRefresh) {
          final cached = await DatabaseService.instance.getRepoTree(
            widget.repository.id,
            _currentPath,
          );
          if (cached != null && cached.isNotEmpty) {
            setState(() {
              _files = cached;
              _isFromCache = true;
              _isLoading = false;
            });
            return;
          }
        }

        // 2. Si no estaba en caché o se pidió refrescar, consultamos a la API de GitHub
        result = await GitHubService.instance.getRepoContents(
          widget.repository.owner,
          widget.repository.name,
          path: _currentPath,
        );

        // 3. Persistimos los resultados en SQLite para navegación offline futura
        await DatabaseService.instance.saveRepoTree(
          widget.repository.id,
          _currentPath,
          result,
        );
        _isFromCache = false;
      } else {
        // Carga simulada local (para repositorios mock)
        result = await LocalDataService.loadRepoFiles();
        _isFromCache = true;
      }

      setState(() {
        _files = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Entra en un subdirectorio guardando la ruta previa en el historial
  void _entrarEnCarpeta(String folderName) {
    _pathHistory.add(_currentPath);
    _currentPath = _currentPath.isEmpty ? folderName : '$_currentPath/$folderName';
    _cargarContenidos();
  }

  /// Retrocede al nivel de carpeta anterior desapilando de _pathHistory
  bool _retrocederCarpeta() {
    if (_pathHistory.isNotEmpty) {
      _currentPath = _pathHistory.removeLast();
      _cargarContenidos();
      return true; // Se gestionó el retroceso interno dentro de carpetas
    }
    return false; // Ya estamos en la raíz: permite el pop estándar de Flutter para volver a HomePage
  }

  @override
  Widget build(BuildContext context) {
    final subTitulo = _currentPath.isEmpty ? 'Raíz del repositorio' : '/$_currentPath';

    // PopScope: Intercepta el botón físico/gesto de volver atrás de Android.
    // Si estamos dentro de subcarpetas (canPop: false), retrocede de nivel en vez de salir de la pantalla.
    return PopScope(
      canPop: _pathHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _retrocederCarpeta();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.fondoPrincipal,
        appBar: AppBar(
          backgroundColor: AppTheme.fondoTarjeta,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.repository.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subTitulo,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isFromCache)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.acentoCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.acentoCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'OFFLINE (CACHÉ)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.acentoCyan,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (!_retrocederCarpeta()) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Forzar recarga remota',
              onPressed: () => _cargarContenidos(forceRefresh: true),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.acentoCyan))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _cargarContenidos(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.acentoCyan,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // ListView.separated:
                // A diferencia de ListView.builder, incluye automáticamente un separatorBuilder
                // para dibujar líneas divisorias tenues (Dividers) entre cada elemento sin tener
                // que calcular márgenes manuales.
                : RefreshIndicator(
                    color: AppTheme.acentoCyan,
                    backgroundColor: AppTheme.fondoTarjeta,
                    onRefresh: () => _cargarContenidos(forceRefresh: true),
                    child: ListView.separated(
                      itemCount: _files.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Colors.white10,
                      ),
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        final isMd = file.isMarkdown;

                        return ListTile(
                          // Diferenciación visual de iconos según el tipo de archivo:
                          // - Carpeta: Icono folder en cyan.
                          // - Archivo Markdown: Icono description en ámbar.
                          // - Archivo común: Icono genérico en gris.
                          leading: Icon(
                            file.isDirectory
                                ? Icons.folder
                                : (isMd ? Icons.description : Icons.insert_drive_file),
                            color: file.isDirectory
                                ? AppTheme.acentoCyan
                                : (isMd ? Colors.amber : Colors.grey),
                          ),
                          title: Text(
                            file.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          // Si es un documento Markdown (.md), mostramos un chip llamativo con el texto "Leer"
                          trailing: isMd
                              ? const Chip(
                                  label: Text(
                                    'Leer',
                                    style: TextStyle(fontSize: 10, color: Colors.black),
                                  ),
                                  backgroundColor: Colors.amber,
                                  visualDensity: VisualDensity.compact,
                                )
                              : null,
                          onTap: () {
                            if (file.isDirectory) {
                              _entrarEnCarpeta(file.name);
                            } else if (file.isMarkdown) {
                              // Si es Markdown, abrimos el visor de documentos (DocumentViewPage)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewPage(
                                    repository: widget.repository,
                                    file: file,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('El archivo "${file.name}" no es Markdown legible.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/git_file_model.dart';
import '../models/repository_model.dart';
import '../services/database_service.dart';
import '../services/github_service.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';

/// Vista principal para la visualización y lectura de documentos Markdown (.md).
/// 
/// ¿Por qué es un StatelessWidget?
/// Porque el documento recibido (o cargado por red/local) no sufre mutaciones interactivas
/// de estado dentro de esta pantalla. La gestión del ciclo de vida asíncrono (carga, error y éxito)
/// se delega por completo a FutureBuilder.
class DocumentViewPage extends StatelessWidget {
  final RepositoryModel repository;
  final GitFileModel file;
  final String? initialContent;

  const DocumentViewPage({
    super.key,
    required this.repository,
    required this.file,
    this.initialContent,
  });

  /// Determina la estrategia de obtención del Markdown:
  /// 1. Si se le pasó contenido inicial en memoria, lo devuelve directamente.
  /// 2. Si el repositorio es remoto (github.com), consulta primero a SQLite (Cache-First).
  ///    Si ya fue visitado o sincronizado, lo devuelve de inmediato sin consumir cuota de red.
  ///    Si no está en SQLite, lo descarga en tiempo real vía GitHubService y lo guarda en caché.
  /// 3. Si es local, lo lee de los assets empaquetados mediante LocalDataService.
  Future<String> _obtenerContenidoMarkdown() async {
    if (initialContent != null) {
      return initialContent!;
    }

    // Si el repositorio proviene de GitHub, aplicamos estrategia Cache-First
    if (repository.htmlUrl.contains('github.com')) {
      // 1. Verificamos si ya existe en la caché local de SQLite
      final cached = await DatabaseService.instance.getMarkdown(repository.id, file.path);
      if (cached != null && cached.isNotEmpty) {
        return cached; // ¡Lectura instantánea offline sin consumir cuota de la API!
      }

      // 2. Si no estaba guardado, lo descargamos de la red
      final remoteContent = await GitHubService.instance.getRawMarkdown(
        repository.owner,
        repository.name,
        file.path,
        downloadUrl: file.downloadUrl,
      );

      // 3. Lo persistimos en SQLite para futuras consultas sin conexión
      await DatabaseService.instance.saveMarkdown(repository.id, file.path, remoteContent);

      return remoteContent;
    }

    // Si es un repositorio mock local, lee desde assets
    return LocalDataService.loadLocalMarkdown(file.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.fondoPrincipal,
      appBar: AppBar(
        backgroundColor: AppTheme.fondoTarjeta,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              file.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              repository.fullName,
              style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartir enlace',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enlace copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      // FutureBuilder gestiona el ciclo de vida asíncrono con el snapshot:
      // 1. Si está cargando (waiting): muestra el círculo de progreso (CircularProgressIndicator).
      // 2. Si ocurre un fallo (hasError): muestra el error correspondiente en pantalla.
      // 3. Si se completa exitosamente: devuelve el widget Markdown() con el contenido parseado y estilizado.
      body: FutureBuilder<String>(
        future: _obtenerContenidoMarkdown(),
        builder: (context, snapshot) {
          // 1. Estado de carga: muestra el círculo
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.acentoCyan),
            );
          } 
          // 2. Estado de error: muestra el mensaje de fallo
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Error al descargar Markdown: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Éxito: devuelve el contenido renderizado con el widget Markdown
          final markdownContent = snapshot.data ?? '# Sin contenido disponible';

          /// Se utiliza el widget Markdown() incluido en la librería externa
          /// 'flutter_markdown' para formatear y renderizar textos Markdown con
          /// estilos visuales y resaltado de código.
          return Markdown(
            data: markdownContent,
            selectable: true, // Permite seleccionar y copiar texto nativamente
            padding: const EdgeInsets.all(16.0),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              // Párrafos con excelente legibilidad y espaciado
              p: const TextStyle(
                color: AppTheme.textoPrincipal,
                height: 1.6,
                fontSize: 14,
              ),
              // Encabezados H1, H2, H3 con jerarquía y color temático
              h1: const TextStyle(
                color: AppTheme.acentoCyan,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              // Código inline (ej. `void main()`)
              code: const TextStyle(
                backgroundColor: AppTheme.fondoTarjeta,
                color: AppTheme.codigoVerde,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              // Bloques de código con fondo diferenciado y borde sutil
              codeblockDecoration: BoxDecoration(
                color: AppTheme.fondoTarjeta,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.bordeSutil),
              ),
              // Citas en bloque (> ...) con barra vertical cyan
              blockquoteDecoration: BoxDecoration(
                color: AppTheme.fondoTarjeta.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  left: BorderSide(color: AppTheme.acentoCyan, width: 4),
                ),
              ),
              // Regla horizontal (---)
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: AppTheme.bordeSutil),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppTheme.fondoTarjeta,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.menu_book, size: 18, color: AppTheme.acentoCyan),
              label: const Text('Tabla de contenidos', style: TextStyle(color: AppTheme.acentoCyan)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sección en desarrollo para el Módulo 09')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              tooltip: 'Buscar en el texto',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/repository_model.dart';
import '../models/git_file_model.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';

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
      body: FutureBuilder<String>(
        future: initialContent != null
            ? Future.value(initialContent)
            : LocalDataService.loadLocalMarkdown(file.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.acentoCyan),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar el documento: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final markdownContent = snapshot.data ?? '# Sin contenido disponible';

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
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.4,
              ),
              h2: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.4,
              ),
              h3: const TextStyle(
                color: AppTheme.acentoCyan,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              // Código inline (ej. `void main()`)
              code: const TextStyle(
                backgroundColor: AppTheme.fondoTarjeta,
                fontFamily: 'monospace',
                color: AppTheme.codigoVerde,
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
                color: AppTheme.fondoTarjeta.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
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
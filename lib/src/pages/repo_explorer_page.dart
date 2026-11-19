import 'package:flutter/material.dart';
import '../models/git_file_model.dart';
import '../models/repository_model.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import 'document_view_page.dart';

/// Pantalla que lista los archivos y carpetas del repositorio seleccionado.
/// 
/// ¿Por qué es un StatelessWidget?
/// Porque en este módulo la pantalla no necesita mutar su estado interno directamente;
/// delega todo el ciclo de vida asíncrono al widget reactivo FutureBuilder.
class RepoExplorerPage extends StatelessWidget {
  /// Recibe el repositorio seleccionado desde HomePage mediante inyección en el constructor.
  final RepositoryModel repository;

  const RepoExplorerPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondoPrincipal,
      appBar: AppBar(
        backgroundColor: AppTheme.fondoTarjeta,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repository.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Raíz del repositorio (Simulado con JSON)',
              style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
            ),
          ],
        ),
      ),
      // FutureBuilder gestiona el ciclo de vida asíncrono de la petición:
      // 1. ConnectionState.waiting: mientras lee los archivos, muestra el spinner central.
      // 2. hasError: si falla la lectura, muestra el mensaje de error correspondiente.
      // 3. hasData / éxito: recibe la lista deserializada List<GitFileModel> y la dibuja.
      body: FutureBuilder<List<GitFileModel>>(
        future: LocalDataService.loadRepoFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.acentoCyan),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar archivos: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final files = snapshot.data ?? [];

          // ListView.separated:
          // A diferencia de ListView.builder, incluye automáticamente un separatorBuilder
          // para dibujar líneas divisorias tenues (Dividers) entre cada elemento sin tener
          // que calcular márgenes manuales.
          return ListView.separated(
            itemCount: files.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Colors.white10,
            ),
            itemBuilder: (context, index) {
              final file = files[index];
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
                  // Si es Markdown, abrimos el visor de documentos (DocumentViewPage)
                  if (file.isMarkdown) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentViewPage(
                          repository: repository,
                          file: file,
                        ),
                      ),
                    );
                  } else if (file.isDirectory) {
                    // Feedback temporal para carpetas (se conectará a GitHub en el siguiente módulo)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Carpeta "${file.name}": La navegación remota se implementará con GitHubService.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

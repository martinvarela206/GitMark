import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../models/git_file_model.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import 'document_view_page.dart';

class RepoExplorerPage extends StatelessWidget {
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
            Text(repository.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Raíz del repositorio (Simulado con JSON)', style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario)),
          ],
        ),
      ),
      body: FutureBuilder<List<GitFileModel>>(
        future: LocalDataService.loadRepoFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.acentoCyan));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final files = snapshot.data ?? [];
          return ListView.separated(
            itemCount: files.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final file = files[index];
              final isMd = file.isMarkdown;

              return ListTile(
                leading: Icon(
                  file.isDirectory
                      ? Icons.folder
                      : (isMd ? Icons.description : Icons.insert_drive_file),
                  color: file.isDirectory
                      ? AppTheme.acentoCyan
                      : (isMd ? Colors.amber : Colors.grey),
                ),
                title: Text(file.name, style: const TextStyle(color: Colors.white)),
                trailing: isMd
                    ? const Chip(
                        label: Text('Leer', style: TextStyle(fontSize: 10, color: Colors.black)),
                        backgroundColor: Colors.amber,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
                onTap: () {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Carpeta "${file.name}": La navegación remota se implementará en el Módulo 06.'),
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
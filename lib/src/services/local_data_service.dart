import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/repository_model.dart';
import '../models/git_file_model.dart';

class LocalDataService {
  // Carga repositorios desde el archivo JSON local (estilo menu_provider en componentes)
  static Future<List<RepositoryModel>> loadRepositories() async {
    final String resp = await rootBundle.loadString('assets/data/repositorios.json');
    final Map<String, dynamic> dataMap = json.decode(resp);
    final List<dynamic> reposJson = dataMap['repositories'];
    return reposJson.map((repo) => RepositoryModel.fromJson(repo)).toList();
  }

  // Carga archivos simulados de un repositorio desde el archivo JSON local
  static Future<List<GitFileModel>> loadRepoFiles() async {
    final String resp = await rootBundle.loadString('assets/data/repo_files.json');
    final List<dynamic> filesJson = json.decode(resp);
    return filesJson.map((file) => GitFileModel.fromJson(file)).toList();
  }

  // Carga un archivo Markdown local desde la carpeta assets/data/
  static Future<String> loadLocalMarkdown(String fileName) async {
    try {
      return await rootBundle.loadString('assets/data/$fileName');
    } catch (e) {
      // Respaldo seguro: si el archivo pedido no existe, carga el README.md principal
      return await rootBundle.loadString('assets/data/README.md');
    }
  }
}
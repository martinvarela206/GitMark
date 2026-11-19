import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/git_file_model.dart';
import '../models/repository_model.dart';

/// Servicio de datos locales para cargar y deserializar archivos empaquetados en los assets.
/// 
/// ¿Por qué todos sus métodos son estáticos (`static`)?
/// Para utilizarlos como herramientas directas (`LocalDataService.loadRepositories()`) sin necesidad
/// de instanciar un objeto del servicio con `new` en cada pantalla, ahorrando memoria y simplificando el código.
/// 
/// A futuro:
/// Este servicio convivirá con 'github_service.dart' (peticiones HTTP reales a GitHub) y
/// 'database_service.dart' (persistencia relacional local en SQLite para repositorios visitados).
class LocalDataService {
  /// Carga y deserializa los repositorios iniciales desde el archivo JSON empaquetado.
  /// 
  /// El proceso consta de tres pasos claros:
  /// 1. rootBundle.loadString: Lee el archivo de texto plano físico dentro del paquete de la app.
  /// 2. json.decode: Parsea el texto plano a un Map/List dinámico en memoria.
  /// 3. .map(...fromJson).toList(): Deserializa cada elemento al modelo inmutable fuertemente tipado.
  static Future<List<RepositoryModel>> loadRepositories() async {
    final String resp = await rootBundle.loadString('assets/data/repositorios.json');
    final Map<String, dynamic> dataMap = json.decode(resp);
    final List<dynamic> reposJson = dataMap['repositories'];
    return reposJson.map((repo) => RepositoryModel.fromJson(repo)).toList();
  }

  /// Carga y deserializa la lista simulada de archivos y carpetas de un repositorio.
  static Future<List<GitFileModel>> loadRepoFiles() async {
    final String resp = await rootBundle.loadString('assets/data/repo_files.json');
    final List<dynamic> filesJson = json.decode(resp);
    return filesJson.map((file) => GitFileModel.fromJson(file)).toList();
  }

  /// Carga el contenido de texto de un archivo Markdown local.
  /// 
  /// Mecanismo de respaldo seguro (Fallback):
  /// Si el archivo solicitado no existe en la carpeta assets/data/, el bloque catch lo
  /// captura de forma transparente y devuelve el 'README.md' principal para que la pantalla
  /// nunca rompa ni se quede con un error visual.
  static Future<String> loadLocalMarkdown(String fileName) async {
    try {
      return await rootBundle.loadString('assets/data/$fileName');
    } catch (e) {
      // Si el archivo particular no está empaquetado, muestra el README por defecto
      return await rootBundle.loadString('assets/data/README.md');
    }
  }
}

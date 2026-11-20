import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/git_file_model.dart';
import '../models/repository_model.dart';
import 'rate_limit_service.dart';

/// Cliente de red para consumir la API pública REST v3 de GitHub.
/// Sigue la arquitectura de servicios desacoplados del Apunte de Cátedra (Sección 8.1).
/// 
/// ¿Por qué es un Singleton (`instance` y `_internal`)?
/// Para centralizar el cliente de red en un único punto de acceso y reutilizar la configuración
/// de encabezados y control de cuota en toda la aplicación.
class GitHubService {
  static final GitHubService instance = GitHubService._internal();
  GitHubService._internal();

  static const String _baseUrl = 'https://api.github.com';

  /// Cabeceras estándar requeridas por la API de GitHub:
  /// - Accept: Solicita explícitamente el formato v3 JSON.
  /// - User-Agent: OBLIGATORIO según los términos de GitHub; peticiones sin este encabezado
  ///   son bloqueadas inmediatamente con error 403 Forbidden.
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'GitMarkApp',
  };

  /// Procesa la respuesta HTTP, alimenta el monitor de cuota y valida el código de estado (status code).
  /// 
  /// Si el código de respuesta está entre 200 y 299, retorna la respuesta exitosa.
  /// En caso contrario (403 cuota excedida, 404 no encontrado), lanza una excepción explicativa.
  http.Response _procesarRespuesta(http.Response response) {
    // Alimenta reactivamente al semáforo de cuota con los encabezados x-ratelimit-*
    RateLimitService.instance.updateFromHeaders(response.headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception('Error en API GitHub (${response.statusCode}): ${response.reasonPhrase}');
    }
  }

  /// Obtiene los metadatos de un repositorio puntual (ej: owner: 'martinvarela206', repo: 'GitMark')
  Future<RepositoryModel> getRepository(String owner, String repo) async {
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo');
    final response = await http.get(url, headers: _headers);
    final valid = _procesarRespuesta(response);

    final Map<String, dynamic> data = jsonDecode(valid.body);
    return RepositoryModel.fromJson(data);
  }

  /// Obtiene el árbol de archivos y directorios de una ruta específica dentro del repositorio.
  Future<List<GitFileModel>> getRepoContents(String owner, String repo, {String path = ''}) async {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$cleanPath');
    final response = await http.get(url, headers: _headers);
    final valid = _procesarRespuesta(response);

    final dynamic decoded = jsonDecode(valid.body);
    if (decoded is List) {
      final List<GitFileModel> files = decoded
          .map((item) => GitFileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Orden pedagógico: directorios primero ('dir') y luego archivos ('file') ordenados alfabéticamente
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return files;
    } else {
      return [GitFileModel.fromJson(decoded as Map<String, dynamic>)];
    }
  }

  /// Descarga el texto en crudo de un archivo Markdown.
  /// 
  /// Estrategia de descarga optimizada:
  /// 1. Si existe 'downloadUrl' directa (raw.githubusercontent.com), se descarga como texto
  ///    plano de forma inmediata para máxima velocidad.
  /// 2. Si no, se consulta el endpoint de contents y se decodifica el Base64 en UTF-8.
  Future<String> getRawMarkdown(String owner, String repo, String path, {String? downloadUrl}) async {
    // 1. Descarga directa si la URL cruda está disponible
    if (downloadUrl != null && downloadUrl.isNotEmpty) {
      final url = Uri.parse(downloadUrl);
      final response = await http.get(url, headers: {'User-Agent': 'GitMarkApp'});
      final valid = _procesarRespuesta(response);
      return valid.body;
    }

    // 2. Fallback: decodificación Base64 desde el endpoint de contents
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$cleanPath');
    final response = await http.get(url, headers: _headers);
    final valid = _procesarRespuesta(response);

    final Map<String, dynamic> data = jsonDecode(valid.body);
    if (data.containsKey('content') && data['encoding'] == 'base64') {
      final String rawBase64 = (data['content'] as String).replaceAll('\n', '').replaceAll('\r', '');
      return utf8.decode(base64.decode(rawBase64));
    }

    throw Exception('No se pudo decodificar el contenido del archivo Markdown.');
  }
}
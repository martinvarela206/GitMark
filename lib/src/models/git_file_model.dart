/// El modelo es un objeto que representa archivo o carpetas en el repositorio o en local.
/// 
/// Modelo inmutable: Como los objetos se pasan por referencia, al hacerlo inmutable 
/// se evitan fallos por modificación de atributos.
/// Ej: Si se cambia name de "Readme.md" a "Readme_borrador.md", se pierde el nombre original y al intentar
/// descargar el archivo, la aplicación fallaria. Al hacerlo inmutable se fuerza la necesidad de realizar una
/// copia del objeto original para cambiar sus valores.
class GitFileModel {
  final String name;
  final String path;
  final String sha;
  final int size;
  final String type; // 'file' o 'dir'
  final String? downloadUrl;

  const GitFileModel({
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    required this.type,
    this.downloadUrl,
  });

  bool get isDirectory => type == 'dir';
  bool get isMarkdown => name.toLowerCase().endsWith('.md');

  /// Constructor factory para deserializar la respuesta JSON en un objeto seguro:
  /// 1. Previene errores de tipeo en compilación: Permite escribir archivo.name 
  ///    en lugar de json['name'] (el cual podria dar lugar a errores
  ///    como json['nmae']), que no serían detectados hasta la ejecución.
  /// 2. Evita valores nulos: si GitHub o el JSON no traen algún dato, se le asigna un valor
  ///    por defecto seguro ('' o 0) para que la interfaz nunca crashee.
  factory GitFileModel.fromJson(Map<String, dynamic> json) {
    return GitFileModel(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      sha: json['sha'] ?? '',
      size: json['size'] ?? 0,
      type: json['type'] ?? 'file',
      downloadUrl: json['download_url'],
    );
  }
}
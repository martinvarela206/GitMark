/// El modelo es un objeto que representa un repositorio completo de GitHub
/// (desde un JSON local o desde la API).
/// 
/// Modelo inmutable: Como los objetos se pasan por referencia, al hacerlo 
/// inmutable se evitan fallos por alteración accidental de sus propiedades 
/// entre pantallas.
/// Ej: Si la pantalla de detalles modificara directamente repo.name a 
/// "Repo_Editado", la lista principal mostraría ese cambio no deseado y 
/// fallaría al consultar la URL original en GitHub. Ser inmutable garantiza
/// que los datos permanezcan íntegros y seguros en toda la aplicación.
class RepositoryModel {
  final String id;
  final String name;
  final String fullName;
  final String owner;
  final String avatarUrl;
  final String description;
  final int starsCount;
  final String language;
  final bool isPrivate;
  final String defaultBranch;
  final String htmlUrl;
  final String repoCategory;

  const RepositoryModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.avatarUrl,
    required this.description,
    required this.starsCount,
    required this.language,
    this.isPrivate = false,
    this.defaultBranch = 'main',
    required this.htmlUrl,
    this.repoCategory = 'public',
  });

  /// Constructor factory para deserializar la respuesta JSON en un objeto
  /// seguro:
  /// 1. Previene errores de tipeo en compilación: Permite escribir
  ///    repo.starsCount, en lugar de json['stargazers_count'] (el cual podria
  ///    dar lugar a errores como json['starazers_cont']), que no serían
  ///    detectados hasta la ejecución.
  /// 2. Evita valores nulos: si GitHub o el JSON no traen algún dato, se le 
  ///    asigna un valor por defecto seguro ('Sin nombre', 0) para que la
  ///    interfaz nunca crashee.
  /// 3. Desempaqueta objetos anidados (como extraer el nombre y avatar desde el mapa 'owner').
  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    final ownerMap = json['owner'];
    return RepositoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Sin nombre',
      fullName: json['full_name'] ?? json['name'] ?? '',
      owner: ownerMap is Map ? (ownerMap['login'] ?? '') : (json['owner']?.toString() ?? ''),
      avatarUrl: ownerMap is Map ? (ownerMap['avatar_url'] ?? '') : '',
      description: json['description'] ?? 'Sin descripción disponible',
      starsCount: json['stargazers_count'] ?? json['stars_count'] ?? 0,
      language: json['language'] ?? 'Markdown',
      isPrivate: json['private'] == true,
      defaultBranch: json['default_branch'] ?? 'main',
      htmlUrl: json['html_url'] ?? '',
      repoCategory: json['repo_category'] ?? 'public',
    );
  }

  /// Convierte el objeto de Dart a un Map, el cual es un diccionario clave-valor muy similar a JSON,
  /// además adapta algunos valores (SQLite no maneja valores booleanos, asi que isPrivate se convierte a 1 o 0)
  /// lo que luego facilita su guardado en la base de datos local (SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'description': description,
      'stars_count': starsCount,
      'language': language,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'is_private': isPrivate ? 1 : 0,
      'default_branch': defaultBranch,
      'repo_category': repoCategory,
    };
  }
}

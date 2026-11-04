// Archivo: lib/src/models/repository_model.dart

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

  // Constructor factory: convierte el Map del JSON en objeto (igual que Dolar.fromJson en dolar_api)
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

  // Convierte el objeto a Map para guardar en la base de datos (igual que toMap en sqflite_carrito)
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

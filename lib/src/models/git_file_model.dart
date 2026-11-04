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

  // Constructor factory (estilo Dolar.fromJson)
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
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/git_file_model.dart';
import '../models/repository_model.dart';

/// Gestor de base de datos relacional local SQLite para Android e iOS.
/// 
/// Singleton es un patrón de diseño, donde solo puede existir UN SOLO OBJETO en
/// toda la aplicación.
/// 
/// ¿Por qué es un Singleton (`instance` y constructor privado `_init`)?
/// Dado que abrir múltiples conexiones concurrentes a un archivo SQLite en un
/// móvil puede bloquear la base de datos (DatabaseLockedException) o corromper
/// datos. El Singleton garantiza que exista un único manejador de conexión
/// abierto en toda la aplicación.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  static const String _tableName = 'repositories';
  static const String _tableTree = 'repo_tree';
  static const String _tableMarkdown = 'markdown_cache';

  /// Getter asíncrono para obtener la instancia activa de la base de datos
  /// (Lazy Loading o carga bajo demanda).
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gitmark.db');
    return _database!;
  }

  /// Inicializa la base de datos en el almacenamiento interno seguro del
  /// dispositivo móvil.
  Future<Database> _initDB(String filePath) async {
    // getDatabasesPath() resuelve la carpeta interna protegida asignada a la
    // app por Android/iOS
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Versión 2: soporte de árbol de archivos y caché de markdown
      onCreate: _onCreateDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  /// Crea la estructura de tablas la primera vez que se ejecuta la app en el
  /// dispositivo.
  /// 
  /// Actúa como las migraciones en Flutter Drift, pero no se uso Flutter Drift
  /// porque añade mas complejidad al proyecto, de la que realmente resuelve en
  /// este caso.
  /// 
  /// El map devuelto por RepositoryModel.toMap() tiene correspondencia con:
  /// - is_private INTEGER: SQLite no posee tipo booleano; se almacena 1 (true) o 0 (false).
  /// - last_accessed INTEGER: Almacena milisegundos Unix para ordenar cronológicamente el historial.
  Future<void> _onCreateDB(Database db, int version) async {
    // 1. Tabla de Repositorios (Metadatos e historial de acceso)
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        full_name TEXT NOT NULL,
        owner TEXT NOT NULL,
        description TEXT,
        stars_count INTEGER,
        language TEXT,
        avatar_url TEXT,
        html_url TEXT,
        is_private INTEGER,
        default_branch TEXT,
        repo_category TEXT,
        last_accessed INTEGER,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // 2. Tabla del Árbol de Archivos y Carpetas (Estructura offline)
    await db.execute('''
      CREATE TABLE $_tableTree (
        id TEXT PRIMARY KEY,
        repo_id TEXT NOT NULL,
        folder_path TEXT NOT NULL,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        type TEXT NOT NULL,
        size INTEGER,
        download_url TEXT
      )
    ''');

    // 3. Tabla de Contenido Markdown en Caché (Lectura sin internet y sin gastar cuota)
    await db.execute('''
      CREATE TABLE $_tableMarkdown (
        id TEXT PRIMARY KEY,
        repo_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        content TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
  }

  /// Maneja la migración de esquemas en caso de versiones preexistentes.
  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN updated_at TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN is_synced INTEGER DEFAULT 0;');
      } catch (_) {}

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableTree (
          id TEXT PRIMARY KEY,
          repo_id TEXT NOT NULL,
          folder_path TEXT NOT NULL,
          name TEXT NOT NULL,
          path TEXT NOT NULL,
          type TEXT NOT NULL,
          size INTEGER,
          download_url TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableMarkdown (
          id TEXT PRIMARY KEY,
          repo_id TEXT NOT NULL,
          file_path TEXT NOT NULL,
          content TEXT NOT NULL,
          cached_at INTEGER NOT NULL
        )
      ''');
    }
  }

  // ============================================================================
  // OPERACIONES SOBRE REPOSITORIOS (METADATOS E HISTORIAL)
  // ============================================================================

  /// Guarda o actualiza un repositorio visitado.
  /// 
  /// - ConflictAlgorithm.replace: Si el repositorio ya existe (mismo id), 
  ///   sobrescribe sus datos (Upsert).
  /// - last_accessed: Estampa la fecha y hora actual para moverlo a la cima del
  ///   historial reciente.
  Future<void> insertOrUpdate(RepositoryModel repo) async {
    // final se pone solo por buena práctica.
    final db = await instance.database;
    final map = repo.toMap();
    map['last_accessed'] = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      _tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retorna los repositorios visitados ordenados del más reciente al más antiguo.
  Future<List<RepositoryModel>> getRecentRepositories({int limit = 10}) async {
    // final se pone solo por buena práctica.
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'last_accessed IS NOT NULL',
      orderBy: 'last_accessed DESC',
      limit: limit,
    );

    return maps.map((m) => RepositoryModel.fromJson(m)).toList();
  }

  /// Retorna el último repositorio visitado para poblar el banner superior de HomePage.
  Future<RepositoryModel?> getLastVisitedRepo() async {
    final list = await getRecentRepositories(limit: 1);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  /// Determina si la base de datos ya contiene registros (detecta el primer ingreso).
  Future<bool> hasRepositories() async {
    // final se pone solo por buena práctica.
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return (count ?? 0) > 0;
  }

  /// Actualiza la bandera de sincronización y fecha remota de un repositorio.
  Future<void> markRepoSynced(String repoId, bool isSynced, {String? updatedAt}) async {
    final db = await instance.database;
    final Map<String, dynamic> values = {
      'is_synced': isSynced ? 1 : 0,
    };
    if (updatedAt != null && updatedAt.isNotEmpty) {
      values['updated_at'] = updatedAt;
    }
    await db.update(
      _tableName,
      values,
      where: 'id = ?',
      whereArgs: [repoId],
    );
  }

  // ============================================================================
  // OPERACIONES SOBRE EL ÁRBOL DE ARCHIVOS (REPO TREE CACHE)
  // ============================================================================

  /// Persiste en SQLite la lista de archivos y subdirectorios de una ruta dada.
  Future<void> saveRepoTree(String repoId, String folderPath, List<GitFileModel> files) async {
    final db = await instance.database;
    final batch = db.batch();

    // Limpia la caché anterior de esta carpeta puntual para evitar duplicados obsoletos
    batch.delete(
      _tableTree,
      where: 'repo_id = ? AND folder_path = ?',
      whereArgs: [repoId, folderPath],
    );

    for (final file in files) {
      batch.insert(
        _tableTree,
        {
          'id': '$repoId:$folderPath:${file.path}',
          'repo_id': repoId,
          'folder_path': folderPath,
          'name': file.name,
          'path': file.path,
          'type': file.type,
          'size': file.size,
          'download_url': file.downloadUrl,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Recupera el árbol de archivos guardado localmente para una carpeta específica.
  /// Si no existe en la base de datos, devuelve null (indicando que debe descargarse).
  Future<List<GitFileModel>?> getRepoTree(String repoId, String folderPath) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTree,
      where: 'repo_id = ? AND folder_path = ?',
      whereArgs: [repoId, folderPath],
    );

    if (maps.isEmpty) return null;

    final files = maps.map((m) => GitFileModel.fromJson(m)).toList();
    files.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return files;
  }

  // ============================================================================
  // OPERACIONES SOBRE CONTENIDO MARKDOWN (OFFLINE READING CACHE)
  // ============================================================================

  /// Almacena el texto completo de un archivo Markdown en la base de datos SQLite.
  Future<void> saveMarkdown(String repoId, String filePath, String content) async {
    final db = await instance.database;
    await db.insert(
      _tableMarkdown,
      {
        'id': '$repoId:$filePath',
        'repo_id': repoId,
        'file_path': filePath,
        'content': content,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene el texto Markdown almacenado en caché para un archivo específico.
  /// Devuelve null si aún no ha sido descargado en el almacenamiento local.
  Future<String?> getMarkdown(String repoId, String filePath) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMarkdown,
      where: 'repo_id = ? AND file_path = ?',
      whereArgs: [repoId, filePath],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['content'] as String?;
    }
    return null;
  }
}
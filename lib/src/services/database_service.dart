import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
      version: 1,
      onCreate: _onCreateDB,
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
        last_accessed INTEGER
      )
    ''');
  }

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
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
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
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return (count ?? 0) > 0;
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/area.dart';

class AreaStorage {
  static Database? _database;

  // Singleton para asegurar que solo haya una conexión abierta
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Busca la ruta por defecto para bases de datos en el dispositivo
    String path = join(await getDatabasesPath(), 'areas_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Creamos la tabla al iniciar por primera vez
        await db.execute('''
          CREATE TABLE areas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            tipo INTEGER,
            imageSeed TEXT
          )
        ''');
      },
    );
  }

  // --- CRUD OPERATIONS ---

  Future<List<Area>> loadAreas() async {
    final db = await database;
    // Query devuelve una lista de mapas
    final List<Map<String, dynamic>> maps = await db.query('areas');

    // Convertimos la lista de mapas a lista de Areas
    return List.generate(maps.length, (i) {
      return Area.fromMap(maps[i]);
    });
  }

  Future<void> addArea(Area area) async {
    final db = await database;
    // Insertamos el mapa, ignorando el ID porque es autoincrementable
    await db.insert(
      'areas',
      area.toMap()..remove('id'), // Removemos null id para que SQLite lo genere
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateArea(String oldName, Area newArea) async {
    final db = await database;
    // Actualizamos donde el nombre coincida con el antiguo
    // NOTA: Idealmente usaríamos ID, pero mantenemos 'oldName' para no romper tu UI actual
    await db.update(
      'areas',
      newArea.toMap()..remove('id'), // No actualizamos el ID
      where: 'name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> deleteArea(String name) async {
    final db = await database;
    await db.delete(
      'areas',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('areas');
  }
}
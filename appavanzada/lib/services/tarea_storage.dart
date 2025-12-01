import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarea.dart';

class TareaStorage {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'tareas_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tareas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            areaId INTEGER,
            nombre TEXT,
            completada INTEGER,
            cantidadFrecuencia INTEGER,
            unidadFrecuencia TEXT,
            ultimaFecha TEXT
          )
        ''');
      },
    );
  }

  // ───────────────────────────────
  // CRUD
  // ───────────────────────────────

  Future<void> addTarea(Tarea tarea) async {
    final db = await database;
    await db.insert(
      'tareas',
      tarea.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tarea>> loadTareasByArea(int areaId) async {
    final db = await database;
    final maps = await db.query(
      'tareas',
      where: 'areaId = ?',
      whereArgs: [areaId],
    );
    return List.generate(maps.length, (i) => Tarea.fromMap(maps[i]));
  }

  Future<void> updateTarea(Tarea tarea) async {
    final db = await database;
    await db.update(
      'tareas',
      tarea.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  Future<void> deleteTarea(int id) async {
    final db = await database;
    await db.delete(
      'tareas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('tareas');
  }
}

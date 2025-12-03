import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importaciones de tus modelos
import '../models/area.dart';
import '../models/tarea.dart'; // CORREGIDO: antes decía .dar

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tareas_hogar.db');

    return await openDatabase(
      path,
      version: 1,
      // IMPORTANTE: Esto activa el borrado en cascada (Foreign Keys)
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  // --------------------------------------------------------
  // CREACIÓN DE TABLAS
  // --------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    // Tabla Areas
    await db.execute('''
      CREATE TABLE areas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        tipo INTEGER,
        imageSeed TEXT
      )
    ''');

    // Tabla Tareas
    // ON DELETE CASCADE asegura que si borras un Área, se borren sus tareas automáticamente
    await db.execute('''
      CREATE TABLE tareas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        areaId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        completada INTEGER DEFAULT 0,
        cantidadFrecuencia INTEGER,
        unidadFrecuencia TEXT,
        ultimaFecha TEXT,
        FOREIGN KEY (areaId) REFERENCES areas(id) ON DELETE CASCADE
      )
    ''');
  }

  // ========================================================
  //                      MÉTODOS: ÁREAS
  // ========================================================

  Future<int> insertArea(Area area) async {
    final db = await database;
    return await db.insert(
      'areas',
      area.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Area>> getAreas() async {
    final db = await database;
    final maps = await db.query('areas', orderBy: 'id ASC');
    return maps.map((e) => Area.fromMap(e)).toList();
  }

  Future<int> updateArea(Area area) async {
    final db = await database;
    return await db.update(
      'areas',
      area.toMap(),
      where: 'id = ?',
      whereArgs: [area.id],
    );
  }

  Future<int> deleteArea(int id) async {
    final db = await database;
    // Gracias al PRAGMA foreign_keys = ON, esto borrará también las tareas asociadas
    return await db.delete('areas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAreas() async {
    final db = await database;
    await db.delete('areas'); // Esto también borrará todas las tareas por cascada
  }

  // ========================================================
  //                      MÉTODOS: TAREAS
  // ========================================================

  Future<int> insertTarea(Tarea tarea) async {
    final db = await database;
    return await db.insert(
      'tareas',
      tarea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tarea>> getTareasPorArea(int areaId) async {
    final db = await database;
    final maps = await db.query(
      'tareas',
      where: 'areaId = ?',
      whereArgs: [areaId],
      orderBy: 'id ASC',
    );
    return maps.map((e) => Tarea.fromMap(e)).toList();
  }

  Future<int> updateTarea(Tarea tarea) async {
    final db = await database;
    return await db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  Future<int> deleteTarea(int id) async {
    final db = await database;
    return await db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearTareas() async {
    final db = await database;
    await db.delete('tareas');
  }

  // Obtener solo tareas completadas (para historial)
  Future<List<Tarea>> getTareasCompletas() async {
    final db = await database;
    final res = await db.query(
      "tareas",
      where: "completada = ?",
      whereArgs: [1], // 1 es true
      orderBy: 'ultimaFecha DESC',
    );
    return res.map((e) => Tarea.fromMap(e)).toList();
  }

  // Obtener solo tareas pendientes (para lista principal)
  Future<List<Tarea>> getTareasPendientes() async {
    final db = await database;
    final res = await db.query(
      'tareas',
      where: 'completada = ?',
      whereArgs: [0], // 0 es false
      orderBy: 'ultimaFecha ASC',
    );
    return res.map((e) => Tarea.fromMap(e)).toList();
  }

  // Obtener lista única de nombres (para sugerencias al crear)
  Future<List<Tarea>> getTodasLasTareasNoRepetidas() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT nombre, MIN(id) as id, MIN(areaId) as areaId, MIN(completada) as completada,
             MIN(cantidadFrecuencia) as cantidadFrecuencia,
             MIN(unidadFrecuencia) as unidadFrecuencia,
             MIN(ultimaFecha) as ultimaFecha
      FROM tareas
      GROUP BY nombre
      ORDER BY nombre ASC
    ''');
    return maps.map((e) => Tarea.fromMap(e)).toList();
  }
}
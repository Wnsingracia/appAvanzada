import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import 'package:appavanzada/db/database_helper.dart'; // Servicio SQLite

// Pantalla que muestra todas las tareas completadas de un mes específico
class PantallaTareasCompletas extends StatefulWidget {
  const PantallaTareasCompletas({super.key});

  @override
  State<PantallaTareasCompletas> createState() =>
      _PantallaTareasCompletasState();
}

class _PantallaTareasCompletasState extends State<PantallaTareasCompletas> {
  // Mes actual mostrado
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Lista de tareas completadas en ese mes
  List<Tarea> _tasks = [];

  // Mapa de areaId -> nombre de área
  Map<int, String> _areaNames = {};

  @override
  void initState() {
    super.initState();
    _loadAreasAndTasks(); // Cargar datos al inicio
  }

  // Cargar áreas y tareas completadas
  Future<void> _loadAreasAndTasks() async {
    final db = DatabaseHelper.instance;

    // Cargar todas las áreas y guardar en un mapa {id: nombre}
    final areas = await db.getAreas();
    _areaNames = {for (var a in areas) a.id!: a.name};

    // Cargar todas las tareas completadas
    final all = await db.getTareasCompletas();

    // Filtrar solo las tareas del mes actual
    final filtered = all.where((t) {
      if (t.ultimaFecha == null) return false;
      final fecha = DateTime.tryParse(t.ultimaFecha!);
      if (fecha == null) return false;
      return fecha.year == _currentMonth.year && fecha.month == _currentMonth.month;
    }).toList();

    if (!mounted) return;
    setState(() => _tasks = filtered);
  }

  // Ir al siguiente mes
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadAreasAndTasks();
  }

  // Ir al mes anterior
  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1_

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import '../models/area.dart'; // Asegúrate de importar esto
import 'package:appavanzada/db/database_helper.dart';

class PantallaTareasCompletas extends StatefulWidget {
  const PantallaTareasCompletas({super.key});

  @override
  State<PantallaTareasCompletas> createState() =>
      _PantallaTareasCompletasState();
}

class _PantallaTareasCompletasState extends State<PantallaTareasCompletas> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Tarea> _tasks = [];

  // DICCIONARIO PARA NOMBRES DE ÁREAS
  // Clave: ID del área (int), Valor: Nombre del área (String)
  Map<int, String> _nombresDeAreas = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final DatabaseHelper db = DatabaseHelper.instance;

    // 1. Cargar Tareas Completas
    final allTasks = await db.getTareasCompletas();

    // 2. Cargar TODAS las Áreas para saber sus nombres
    final allAreas = await db.getAreas(); // Asegúrate de tener este método en DatabaseHelper

    // 3. Crear el diccionario ID -> Nombre
    final Map<int, String> areaMap = {};
    for (var area in allAreas) {
      if (area.id != null) {
        areaMap[area.id!] = area.name;
      }
    }

    // 4. Filtrar tareas por mes
    final filteredTasks = allTasks.where((t) {
      if (t.ultimaFecha == null) return false;
      final fecha = DateTime.tryParse(t.ultimaFecha!);
      if (fecha == null) return false;
      return fecha.year == _currentMonth.year &&
          fecha.month == _currentMonth.month;
    }).toList();

    if (!mounted) return;
    setState(() {
      _tasks = filteredTasks;
      _nombresDeAreas = areaMap; // Guardamos el mapa
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final String monthName = DateFormat('MMMM', 'es_ES').format(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFF0A85FF),
      body: SafeArea(
        child: Column(
          children: [
            // BARRA SUPERIOR
            Row(
              children: [
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Completado",
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Para equilibrar el icono de atrás
              ],
            ),

            // SELECTOR DE MES
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.blue, size: 40),
                    onPressed: _prevMonth,
                  ),
                  Text(
                    monthName[0].toUpperCase() + monthName.substring(1),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: Colors.blue, size: 40),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            // LISTA DE TAREAS
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF74B8FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _tasks.isEmpty
                    ? const Center(
                  child: Text(
                    "No hay tareas este mes",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, i) {
                    final t = _tasks[i];
                    // Parsear fecha
                    DateTime? fecha;
                    try { fecha = DateTime.parse(t.ultimaFecha!); } catch(_) {}

                    final fechaStr = fecha != null
                        ? DateFormat("d MMM (EEE) - HH:mm", "es_ES").format(fecha)
                        : "Fecha desconocida";

                    // BUSCAR EL NOMBRE REAL USANDO EL DICCIONARIO
                    final nombreArea = _nombresDeAreas[t.areaId] ?? "Área desconocida";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Etiqueta del Área
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Area",
                                style: TextStyle(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Nombre del Área (REAL)
                            Text(
                              nombreArea,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Detalle Tarea
                            Text(fechaStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              t.nombre,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
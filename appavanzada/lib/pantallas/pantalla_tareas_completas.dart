import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import 'package:appavanzada/db/database_helper.dart'; // TU SERVICIO SQLITE

class PantallaTareasCompletas extends StatefulWidget {
  const PantallaTareasCompletas({super.key});

  @override
  State<PantallaTareasCompletas> createState() =>
      _PantallaTareasCompletasState();
}

class _PantallaTareasCompletasState extends State<PantallaTareasCompletas> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Tarea> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  //  Cargar tareas desde SQLite según el mes actual
  Future<void> _loadTasks() async {
    final DatabaseHelper db = DatabaseHelper.instance;

    // Obtener todas las tareas COMPLETADAS
    final all = await db.getTareasCompletas();

    // Filtrar por mes
    final filtered = all.where((t) {
      if (t.ultimaFecha == null) return false;
      final fecha = DateTime.tryParse(t.ultimaFecha!);
      if (fecha == null) return false;

      return fecha.year == _currentMonth.year &&
          fecha.month == _currentMonth.month;
    }).toList();

    setState(() => _tasks = filtered);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadTasks();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final String monthName = DateFormat('MMMM', 'es_ES').format(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFF0A85FF),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------- TOP BAR ----------------------
            Row(
              children: [
                SizedBox(width: 25),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 60),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    "Completado",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------- MONTH SELECTOR ----------------------
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT ARROW
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_left,
                      color: Color.fromARGB(255, 0, 26, 255),
                      size: 40,
                    ),
                    onPressed: _prevMonth,
                  ),

                  Text(
                    monthName[0].toUpperCase() + monthName.substring(1),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 65, 128, 253),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // RIGHT ARROW
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_right,
                      color: Color.fromARGB(255, 4, 0, 255),
                      size: 40,
                    ),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---------------------- TASKS LIST ----------------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF74B8FF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: _tasks.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay tareas completadas este mes",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tasks.length,
                          itemBuilder: (context, i) {
                            final t = _tasks[i];
                            final fecha = DateTime.parse(t.ultimaFecha!);
                            final fechaStr = DateFormat(
                              "d MMM (EEE) - HH:mm",
                              "es_ES",
                            ).format(fecha);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AREA LABEL
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5A3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Area",
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // AREA NAME
                                Text(
                                  _getAreaName(t.areaId),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // TASK DETAIL
                                Text(
                                  fechaStr,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  t.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Divider(color: Colors.blue.shade200),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtén el nombre del área según su ID
  String _getAreaName(int id) {
    // Luego puedes reemplazar esto con tu tabla real de Áreas en SQLite
    switch (id) {
      case 1:
        return "Cocina";
      case 2:
        return "Sala";
      case 3:
        return "Baño";
      default:
        return "Área desconocida";
    }
  }
}

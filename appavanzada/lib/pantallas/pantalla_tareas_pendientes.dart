import 'package:appavanzada/db/database_helper.dart';
import 'package:appavanzada/models/tarea.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra las tareas pendientes
class PantallaTareasPendientes extends StatefulWidget {
  const PantallaTareasPendientes({super.key});

  @override
  State<PantallaTareasPendientes> createState() =>
      _PantallaTareasPendientesState();
}

class _PantallaTareasPendientesState extends State<PantallaTareasPendientes> {
  // Lista de tareas cargadas desde SQLite
  List<Tarea> _tasks = [];

  // Filtro de tiempo: "Hoy", "Atrasadas", "Próximos 7 días", "Todas"
  String filtroTiempo = "Todas";

  // Forma de agrupar la lista: por "Fecha" o por "Área"
  String agruparPor = "Fecha";

  @override
  void initState() {
    super.initState();
    _loadPendingTasks(); // Cargar tareas pendientes al iniciar
  }

  /// --- Cargar todas las tareas pendientes desde SQLite ---
  Future<void> _loadPendingTasks() async {
    final db = DatabaseHelper.instance;
    final all = await db.getTareasPendientes();
    setState(() => _tasks = all); // Actualizar el estado con las tareas
  }

  /// --- Convertir una fecha String a DateTime ---
  DateTime? parseFecha(String? f) {
    if (f == null) return null;

    try {
      return DateTime.parse(f); // Formato ISO
    } catch (_) {}

    try {
      final p = f.split("-");
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}

    try {
      final p = f.split("/");
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}

    return null; // No se pudo parsear
  }

  /// --- Calcular la próxima fecha según la frecuencia de la tarea ---
  DateTime? getProximaFecha(Tarea t) {
    final f = parseFecha(t.ultimaFecha);
    if (f == null) return null;
    if (t.cantidadFrecuencia == null || t.unidadFrecuencia == null) return null;

    switch (t.unidadFrecuencia) {
      case "días":
        return f.add(Duration(days: t.cantidadFrecuencia!));
      case "semanas":
        return f.add(Duration(days: 7 * t.cantidadFrecuencia!));
      case "meses":
        return DateTime(f.year, f.month + t.cantidadFrecuencia!, f.day);
      case "años":
        return DateTime(f.year + t.cantidadFrecuencia!, f.month, f.day);
      default:
        return null;
    }
  }

  /// --- Calcular los días restantes hasta la próxima fecha ---
  int? diasRestantes(Tarea t) {
    final prox = getProximaFecha(t);
    if (prox == null) return null;
    return prox.difference(DateTime.now()).inDays;
  }

  /// --- Aplicar filtro de tiempo a las tareas ---
  List<Tarea> applyFilters() {
    List<Tarea> result = [..._tasks];

    result = result.where((t) {
      final dr = diasRestantes(t);

      if (dr == null) return true; // Mantener tareas sin fecha

      switch (filtroTiempo) {
        case "Hoy":
          return dr == 0;
        case "Atrasadas":
          return dr < 0;
        case "Próximos 7 días":
          return dr >= 0 && dr <= 7;
        case "Todas":
        default:
          return true;
      }
    }).toList();

    return result;
  }

  /// --- Obtener nombre del área según su ID ---
  String getAreaName(int id) {
    // Cambiar esto si tienes una tabla real de áreas en SQLite
    switch (id) {
      case 1:
        return "Cocina";
      case 2:
        return "Sala";
      case 3:
        return "Baño";
      case 4:
        return "Comedor";
      case 5:
        return "Dormitorio";
      default:
        return "Área desconocida";
    }
  }

  /// --- Agrupar tareas por área o dejar todas juntas por fecha ---
  Map<String, List<Tarea>> groupTasks(List<Tarea> tasks) {
    if (agruparPor == "Área") {
      final Map<String, List<Tarea>> grouped = {};
      for (var t in tasks) {
        final area = getAreaName(t.areaId);
        if (!grouped.containsKey(area)) grouped[area] = [];
        grouped[area]!.add(t);
      }
      return grouped;
    } else {
      // Agrupar por fecha: todas juntas
      return {"": tasks};
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = applyFilters(); // Aplicar filtro de tiempo
    final grouped = groupTasks(filtered); // Agrupar según configuración

    return Scaffold(
      backgroundColor: const Color(0xFF0A85FF),
      body: SafeArea(
        child: Column(
          children: [
            // ------------------ FLECHA + TÍTULO ------------------
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Pendientes",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40), // espacio para balancear el Row
              ],
            ),

            // ------------------ FILTROS ------------------
            Container(
              color: const Color(0xFF0A85FF),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Agrupar por :", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: agruparPor,
                    dropdownColor: Colors.blue,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "Fecha", child: Text("Fecha")),
                      DropdownMenuItem(value: "Área", child: Text("Área")),
                    ],
                    onChanged: (v) => setState(() => agruparPor = v!),
                  ),
                ],
              ),
            ),

            // ------------------ LISTA DE TAREAS ------------------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF74B8FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: grouped.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay tareas pendientes",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: grouped.entries.expand((entry) {
                          final areaName = entry.key; // Nombre del grupo
                          final tareas = entry.value; // Tareas dentro del grupo

                          List<Widget> widgets = [];

                          // Si se agrupa por área, agregar subtítulo
                          if (agruparPor == "Área") {
                            widgets.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  areaName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }

                          // Iterar sobre las tareas de cada grupo
                          for (var t in tareas) {
                            final dr = diasRestantes(t);
                            final prox = getProximaFecha(t);

                            widgets.add(Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t.nombre,
                                          style: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        getAreaName(t.areaId),
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Mostrar próxima fecha si existe
                                  if (prox != null)
                                    Text(
                                      "Próxima fecha: ${DateFormat('d MMM yyyy', 'es_ES').format(prox)}",
                                    ),
                                  // Mostrar días restantes
                                  if (dr != null)
                                    Text(
                                      dr < 0 ? "Atrasada por ${dr.abs()} días" : "Faltan $dr días",
                                      style: TextStyle(
                                        color: dr < 0 ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ));
                          }

                          return widgets;
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

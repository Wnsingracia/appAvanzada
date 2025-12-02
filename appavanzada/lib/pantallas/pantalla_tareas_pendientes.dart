import 'package:appavanzada/db/database_helper.dart';
import 'package:appavanzada/models/tarea.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PantallaTareasPendientes extends StatefulWidget {
  const PantallaTareasPendientes({super.key});

  @override
  State<PantallaTareasPendientes> createState() =>
      _PantallaTareasPendientesState();
}

class _PantallaTareasPendientesState extends State<PantallaTareasPendientes> {
  List<Tarea> _tasks = [];
  String filtroTiempo = "Hoy";
  String agruparPor = "Fecha";

  @override
  void initState() {
    super.initState();
    _loadPendingTasks();
  }

  /// --- Cargar tareas desde SQLite ---
  Future<void> _loadPendingTasks() async {
    final DatabaseHelper db = DatabaseHelper.instance;
    final all = await db.getTareasPendientes();

    setState(() {
      _tasks = all;
    });
  }

  /// --- Convertir fecha String a DateTime ---
  DateTime? parseFecha(String? f) {
    if (f == null) return null;

    try {
      return DateTime.parse(f); // formato ISO
    } catch (_) {}

    // dd-MM-yyyy
    try {
      final p = f.split("-");
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}

    // dd/MM/yyyy
    try {
      final p = f.split("/");
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}

    return null;
  }

  /// --- Calcular próxima fecha según frecuencia ---
  DateTime? getProximaFecha(Tarea t) {
    final f = parseFecha(t.ultimaFecha);
    if (f == null) return null;

    if (t.cantidadFrecuencia == null || t.unidadFrecuencia == null) {
      return null;
    }

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

  /// --- Calcular días restantes ---
  int? diasRestantes(Tarea t) {
    final prox = getProximaFecha(t);
    if (prox == null) return null;

    return prox.difference(DateTime.now()).inDays;
  }

  /// --- Aplicar filtro de tiempo ---
  List<Tarea> applyFilters() {
    List<Tarea> result = [..._tasks];

    result = result.where((t) {
      final dr = diasRestantes(t);
      if (dr == null) return false;

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

  @override
  Widget build(BuildContext context) {
    final filtered = applyFilters();
    return Scaffold(
      backgroundColor: const Color(0xFF0A85FF),
      body: SafeArea(
        child: Column(
          children: [
            // ------------------ FLECHA + TÍTULO ------------------
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: Colors.white,
                  ),
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
                const SizedBox(width: 40),
              ],
            ),

            // ------------------ FILTROS ------------------
            Container(
              color: const Color(0xFF0A85FF),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: const [
                      Text(
                        "Debido\nDentro :",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  DropdownButton<String>(
                    value: filtroTiempo,
                    dropdownColor: Colors.blue,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "Hoy", child: Text("Hoy")),
                      DropdownMenuItem(
                        value: "Atrasadas",
                        child: Text("Atrasadas"),
                      ),
                      DropdownMenuItem(
                        value: "Próximos 7 días",
                        child: Text("Próximos 7 días"),
                      ),
                      DropdownMenuItem(value: "Todas", child: Text("Todas")),
                    ],
                    onChanged: (v) => setState(() => filtroTiempo = v!),
                  ),

                  Column(
                    children: const [
                      Text(
                        "Agrupar\npor :",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

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

            // ------------------ LISTA DE PENDIENTES ------------------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF74B8FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay tareas pendientes",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final t = filtered[i];
                          final dr = diasRestantes(t);
                          final prox = getProximaFecha(t);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (prox != null)
                                  Text(
                                    "Próxima fecha: ${DateFormat('d MMM yyyy', 'es_ES').format(prox)}",
                                  ),
                                if (dr != null)
                                  Text(
                                    dr < 0
                                        ? "Atrasada por ${dr.abs()} días"
                                        : "Faltan $dr días",
                                    style: TextStyle(
                                      color: dr < 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
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

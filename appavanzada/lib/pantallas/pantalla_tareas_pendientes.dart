import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart'; // Asegúrate que la ruta sea correcta
import '../models/tarea.dart';

class PantallaTareasPendientes extends StatefulWidget {
  const PantallaTareasPendientes({super.key});

  @override
  State<PantallaTareasPendientes> createState() =>
      _PantallaTareasPendientesState();
}

class _PantallaTareasPendientesState extends State<PantallaTareasPendientes> {
  List<Tarea> _tasks = [];
  Map<int, String> _nombresDeAreas = {}; // Diccionario ID -> Nombre Área

  String filtroTiempo = "Hoy";
  String agruparPor = "Fecha";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// --- Cargar tareas y áreas desde SQLite ---
  Future<void> _loadData() async {
    final DatabaseHelper db = DatabaseHelper.instance;

    // 1. Cargar Tareas Pendientes
    final tasks = await db.getTareasPendientes();

    // 2. Cargar Áreas para obtener sus nombres
    final areas = await db.getAreas();
    final Map<int, String> areaMap = {};
    for (var area in areas) {
      if (area.id != null) {
        areaMap[area.id!] = area.name;
      }
    }

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _nombresDeAreas = areaMap;
    });
  }

  /// --- Convertir fecha String a DateTime ---
  DateTime? parseFecha(String? f) {
    if (f == null) return null;
    try {
      return DateTime.parse(f);
    } catch (_) {}
    return null;
  }

  /// --- Calcular próxima fecha ---
  DateTime? getProximaFecha(Tarea t) {
    final f = parseFecha(t.ultimaFecha);
    if (f == null) return null; // Si es nueva, asumimos "hoy" o null

    // Si no tiene frecuencia definida, no podemos calcular próxima
    if (t.cantidadFrecuencia == null || t.unidadFrecuencia == null) {
      return f;
    }

    switch (t.unidadFrecuencia) {
      case "Dias": // Ojo: Asegúrate que en la DB guardas "Dias" o "días"
      case "días":
        return f.add(Duration(days: t.cantidadFrecuencia!));
      case "Semanas":
      case "semanas":
        return f.add(Duration(days: 7 * t.cantidadFrecuencia!));
      case "Meses":
      case "meses":
        return DateTime(f.year, f.month + t.cantidadFrecuencia!, f.day);
      default:
        return f.add(Duration(days: t.cantidadFrecuencia!));
    }
  }

  /// --- Calcular días restantes ---
  int? diasRestantes(Tarea t) {
    // Si no hay última fecha, es una tarea nueva, se asume "para hoy" (0 días)
    if (t.ultimaFecha == null) return 0;

    final prox = getProximaFecha(t);
    if (prox == null) return 0;

    final hoy = DateTime.now();
    // Normalizamos fechas para ignorar horas/minutos
    final fechaProx = DateTime(prox.year, prox.month, prox.day);
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

    return fechaProx.difference(fechaHoy).inDays;
  }

  /// --- Filtrar y Ordenar ---
  List<Tarea> applyFiltersAndSort() {
    // 1. Filtrar
    List<Tarea> result = _tasks.where((t) {
      final dr = diasRestantes(t);
      // Si dr es null, asumimos que se muestra siempre o nunca, aquí asumimos se muestra
      if (dr == null) return true;

      switch (filtroTiempo) {
        case "Hoy":
          return dr <= 0; // Incluye atrasadas y las de hoy
        case "Atrasadas":
          return dr < 0;
        case "Próximos 7 días":
          return dr >= 0 && dr <= 7;
        case "Todas":
        default:
          return true;
      }
    }).toList();

    // 2. Ordenar (Agrupar)
    result.sort((a, b) {
      if (agruparPor == "Área") {
        // Ordenar alfabéticamente por nombre de área
        final nombreA = _nombresDeAreas[a.areaId] ?? "";
        final nombreB = _nombresDeAreas[b.areaId] ?? "";
        return nombreA.compareTo(nombreB);
      } else {
        // Por defecto: Ordenar por urgencia (días restantes)
        final drA = diasRestantes(a) ?? 999;
        final drB = diasRestantes(b) ?? 999;
        return drA.compareTo(drB);
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = applyFiltersAndSort();

    return Scaffold(
      backgroundColor: const Color(0xFF0A85FF),
      body: SafeArea(
        child: Column(
          children: [
            // ------------------ HEADER ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
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
                  const SizedBox(width: 48), // Balance visual
                ],
              ),
            ),

            // ------------------ FILTROS ------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // FILTRO TIEMPO
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mostrar:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      DropdownButton<String>(
                        value: filtroTiempo,
                        dropdownColor: Colors.blue[800],
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        underline: Container(height: 1, color: Colors.white54),
                        items: const [
                          DropdownMenuItem(value: "Hoy", child: Text("Para Hoy")),
                          DropdownMenuItem(value: "Atrasadas", child: Text("Atrasadas")),
                          DropdownMenuItem(value: "Próximos 7 días", child: Text("Semana")),
                          DropdownMenuItem(value: "Todas", child: Text("Todas")),
                        ],
                        onChanged: (v) => setState(() => filtroTiempo = v!),
                      ),
                    ],
                  ),

                  // FILTRO GRUPO
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Ordenar por:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      DropdownButton<String>(
                        value: agruparPor,
                        dropdownColor: Colors.blue[800],
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        underline: Container(height: 1, color: Colors.white54),
                        items: const [
                          DropdownMenuItem(value: "Fecha", child: Text("Urgencia")),
                          DropdownMenuItem(value: "Área", child: Text("Área")),
                        ],
                        onChanged: (v) => setState(() => agruparPor = v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ------------------ LISTA ------------------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6FF), // Fondo más claro para leer mejor
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: filtered.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "¡Todo al día!",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final t = filtered[i];
                    final dr = diasRestantes(t) ?? 0;
                    final prox = getProximaFecha(t);
                    final nombreArea = _nombresDeAreas[t.areaId] ?? "General";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Indicador visual de urgencia
                          Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: dr < 0 ? Colors.red : (dr == 0 ? Colors.orange : Colors.green),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Datos de la tarea
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chip del Área
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    nombreArea.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Nombre Tarea
                                Text(
                                  t.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Fecha
                                if (prox != null)
                                  Text(
                                    "Para: ${DateFormat('d MMM', 'es_ES').format(prox)} (${dr < 0 ? 'Atrasada ${dr.abs()} días' : (dr == 0 ? 'Hoy' : 'En $dr días')})",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: dr < 0 ? Colors.red : Colors.grey[700],
                                      fontWeight: dr < 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Checkbox falso o icono de acción
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.grey[400],
                            size: 28,
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
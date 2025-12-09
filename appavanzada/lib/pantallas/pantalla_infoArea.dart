import 'package:flutter/material.dart';
import '../models/area.dart'; // Modelo Area
import '../models/tarea.dart'; // Modelo Tarea
import '../db/database_helper.dart'; // Base de datos
import 'pantalla_nueva_tarea.dart'; // Para agregar nuevas tareas

// Pantalla que muestra información de un área específica y sus tareas
class InfoArea extends StatefulWidget {
  final Area area; // Área seleccionada

  const InfoArea({super.key, required this.area});

  @override
  State<InfoArea> createState() => _InfoAreaState();
}

class _InfoAreaState extends State<InfoArea> {
  final DatabaseHelper _db = DatabaseHelper.instance; // Instancia de base de datos
  List<Tarea> _tareas = []; // Lista de tareas del área

  @override
  void initState() {
    super.initState();
    _loadTareas(); // Cargar tareas al iniciar
  }

  // --- Cargar tareas desde la base de datos para esta área ---
  Future<void> _loadTareas() async {
    final cargadas = await _db.getTareasPorArea(widget.area.id!);
    if (!mounted) return; // Evitar errores si el widget ya no está en pantalla
    setState(() => _tareas = cargadas);
  }

  // --- Cambiar estado de completada/no completada de una tarea ---
  Future<void> _toggleCompletada(Tarea tarea) async {
    final nueva = Tarea(
      id: tarea.id,
      areaId: tarea.areaId,
      nombre: tarea.nombre,
      completada: !tarea.completada, // Cambiar valor
      cantidadFrecuencia: tarea.cantidadFrecuencia,
      unidadFrecuencia: tarea.unidadFrecuencia,
      ultimaFecha: tarea.ultimaFecha,
    );
    await _db.updateTarea(nueva); // Guardar en DB
    _loadTareas(); // Recargar lista
  }

  // --- Eliminar una tarea de la base de datos ---
  Future<void> _eliminarTarea(Tarea tarea) async {
    if (tarea.id == null) return;
    await _db.deleteTarea(tarea.id!);
    _loadTareas(); // Recargar lista después de eliminar
  }

  // --- Mostrar confirmación antes de eliminar ---
  void _showDeleteConfirm(Tarea tarea) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar tarea"),
        content: Text("¿Seguro que deseas eliminar '${tarea.nombre}'?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Sí", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _eliminarTarea(tarea); // Llamar función de eliminación
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener imagen representativa del área
    final imageUrl = widget.area.imageUrlForArea(widget.area.name);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- ENCABEZADO CON NOMBRE DEL ÁREA Y BOTÓN ATRÁS ---
            Container(
              height: 110,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0095FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 25),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Volver a la pantalla anterior
                    },
                  ),
                  const SizedBox(width: 75),
                  Center(
                    child: Text(
                      widget.area.name, // Mostrar nombre del área
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- LISTA DE TAREAS ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tareas.length,
                itemBuilder: (context, index) {
                  final tarea = _tareas[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      // --- Checkbox para marcar completada ---
                      leading: Checkbox(
                        value: tarea.completada,
                        activeColor: const Color(0xFF0095FF),
                        onChanged: (_) => _toggleCompletada(tarea),
                      ),
                      // --- Nombre de la tarea ---
                      title: Text(
                        tarea.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: tarea.completada
                              ? TextDecoration.lineThrough
                              : TextDecoration.none, // Tachado si completada
                        ),
                      ),
                      // --- Subtítulo con frecuencia de la tarea ---
                      subtitle: (tarea.cantidadFrecuencia != null &&
                              tarea.unidadFrecuencia != null)
                          ? Text(
                              "Cada ${tarea.cantidadFrecuencia} ${tarea.unidadFrecuencia}",
                              style: const TextStyle(fontSize: 13),
                            )
                          : null,
                      // --- Botón de eliminar tarea ---
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirm(tarea),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // --- BOTÓN PARA AÑADIR NUEVA TAREA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095FF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 26, color: Colors.white),
                label: const Text(
                  "Añadir tarea",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () async {
                  // Navegar a pantalla de nueva tarea
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PantallaNuevaTarea(areaId: widget.area.id!),
                    ),
                  );
                  _loadTareas(); // Recargar lista después de agregar
                },
              ),
            ),

            const SizedBox(height: 12),

            // --- IMAGEN REPRESENTATIVA DEL ÁREA ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.c

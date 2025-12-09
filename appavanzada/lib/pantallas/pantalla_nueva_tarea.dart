import 'package:flutter/material.dart';
import '../db/database_helper.dart'; // Base de datos SQLite
import '../models/tarea.dart'; // Modelo de tarea
import 'pantalla_ajustar_tarea.dart'; // Pantalla para ajustar detalles de la tarea

// Pantalla para seleccionar o crear una nueva tarea en un área específica
class PantallaNuevaTarea extends StatefulWidget {
  final int areaId; // ID del área donde se añadirá la tarea

  const PantallaNuevaTarea({super.key, required this.areaId});

  @override
  State<PantallaNuevaTarea> createState() => _PantallaNuevaTareaState();
}

class _PantallaNuevaTareaState extends State<PantallaNuevaTarea> {
  List<Tarea> tareasExistentes = []; // Lista de tareas ya existentes
  String? tareaSeleccionada; // Tarea seleccionada por el usuario

  @override
  void initState() {
    super.initState();
    _cargarTareas(); // Cargar tareas existentes al iniciar la pantalla
  }

  // --- Cargar tareas de la base de datos ---
  Future<void> _cargarTareas() async {
    final db = DatabaseHelper.instance;
    final tareas = await db.getTodasLasTareasNoRepetidas(); // Obtener todas las tareas únicas

    if (!mounted) return;
    setState(() {
      tareasExistentes = tareas; // Actualizar la lista visible
    });
  }

  // --- Mostrar popup para agregar tarea personalizada ---
  void _mostrarPopupAdicionarTarea() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adicionar Tarea"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nombre de la Tarea",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar popup
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              String nombre = controller.text.trim(); // Limpiar espacios

              if (nombre.length < 2) {
                // Validación de longitud mínima
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nombre muy corto")),
                );
                return;
              }

              // Comprobar si la tarea ya existe
              bool existe = tareasExistentes.any(
                (t) => t.nombre.toLowerCase() == nombre.toLowerCase(),
              );

              if (!existe) {
                setState(() {
                  tareaSeleccionada = nombre; // Seleccionar la nueva tarea
                });
              }

              // Abrir pantalla para ajustar detalles de la tarea
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaAjustarTarea(
                    areaId: widget.areaId,
                    nombreTarea: tareaSeleccionada!,
                  ),
                ),
              );
            },
            child: const Text("Añadir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: const Text(
          "Seleccione nueva tarea",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- Lista de tareas existentes ---
          Expanded(
            child: ListView.builder(
              itemCount: tareasExistentes.length,
              itemBuilder: (context, index) {
                final tarea = tareasExistentes[index];
                final seleccionada = tareaSeleccionada == tarea.nombre;

                return ListTile(
                  title: Text(tarea.nombre),
                  trailing: seleccionada
                      ? const Icon(Icons.check_circle, color: Color(0xFF0095FF))
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    setState(() {
                      tareaSeleccionada = tarea.nombre; // Selección de tarea
                    });
                  },
                );
              },
            ),
          ),

          // --- Botón para adicionar tarea personalizada ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0095FF),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _mostrarPopupAdicionarTarea, // Mostrar popup
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Adicionar Tarea",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // --- Botón para continuar a ajustar la tarea ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tareaSeleccionada == null
                    ? Colors.grey
                    : const Color(0xFF0095FF), // Inactivo si no hay selección
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: tareaSeleccionada == null
                  ? null // Deshabilitado si no hay tarea seleccionada
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaAjustarTarea(
                            areaId: widget.areaId,
                            nombreTarea: tareaSeleccionada!,
                          ),
                        ),
                      );
                    },
              child: const Text("Siguiente"),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Resumen de la página ---
// Esta pantalla permite al usuario seleccionar una tarea existente o crear una nueva para un área específica.
// - Muestra una lista de tareas ya registradas.
// - Permite crear tareas personalizadas mediante un popup.
// - Después de seleccionar o crear una tarea, el usuario puede avanzar a la pantalla de ajuste de detalles (PantallaAjustarTarea).

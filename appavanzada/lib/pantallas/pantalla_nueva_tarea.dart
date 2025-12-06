import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/tarea.dart';
import 'pantalla_ajustar_tarea.dart';

class PantallaNuevaTarea extends StatefulWidget {
  final int areaId;

  const PantallaNuevaTarea({super.key, required this.areaId});

  @override
  State<PantallaNuevaTarea> createState() => _PantallaNuevaTareaState();
}

class _PantallaNuevaTareaState extends State<PantallaNuevaTarea> {
  List<Tarea> tareasExistentes = [];
  String? tareaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    final db = DatabaseHelper.instance;
    final tareas = await db.getTodasLasTareasNoRepetidas();

    if (!mounted) return;
    setState(() {
      tareasExistentes = tareas;
    });
  }

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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              String nombre = controller.text.trim();

              if (nombre.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nombre muy corto")),
                );
                return;
              }

              bool existe = tareasExistentes.any(
                (t) => t.nombre.toLowerCase() == nombre.toLowerCase(),
              );

              if (!existe) {
                setState(() {
                  tareaSeleccionada = nombre;
                });
              }

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
                      tareaSeleccionada = tarea.nombre;
                    });
                  },
                );
              },
            ),
          ),

          // BOTÓN ADICIONAR
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
              onPressed: _mostrarPopupAdicionarTarea,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Adicionar Tarea",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // BOTÓN SIGUIENTE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tareaSeleccionada == null
                    ? Colors.grey
                    : const Color(0xFF0095FF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: tareaSeleccionada == null
                  ? null
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

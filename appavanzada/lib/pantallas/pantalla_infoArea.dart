import 'package:flutter/material.dart';
import '../models/area.dart';
import '../models/tarea.dart';
import '../db/database_helper.dart';
import 'pantalla_nueva_tarea.dart';

class InfoArea extends StatefulWidget {
  final Area area;

  const InfoArea({super.key, required this.area});

  @override
  State<InfoArea> createState() => _InfoAreaState();
}

class _InfoAreaState extends State<InfoArea> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Tarea> _tareas = [];

  @override
  void initState() {
    super.initState();
    _loadTareas();
  }

  Future<void> _loadTareas() async {
    final cargadas = await _db.getTareasPorArea(widget.area.id!);
    if (!mounted) return;
    setState(() => _tareas = cargadas);
  }

  Future<void> _toggleCompletada(Tarea tarea) async {
    final nueva = Tarea(
      id: tarea.id,
      areaId: tarea.areaId,
      nombre: tarea.nombre,
      completada: !tarea.completada,
      cantidadFrecuencia: tarea.cantidadFrecuencia,
      unidadFrecuencia: tarea.unidadFrecuencia,
      ultimaFecha: tarea.ultimaFecha,
    );
    await _db.updateTarea(nueva);
    _loadTareas();
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    if (tarea.id == null) return;
    await _db.deleteTarea(tarea.id!);
    _loadTareas();
  }

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
              _eliminarTarea(tarea);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.area.imageUrlForArea(widget.area.name);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ENCABEZADO AZUL
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
                SizedBox(width: 25),
                  IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 75),
                  Center(
                    child: Text(
                      widget.area.name,
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

            // LISTA DE TAREAS
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
                      leading: Checkbox(
                        value: tarea.completada,
                        activeColor: const Color(0xFF0095FF),
                        onChanged: (_) => _toggleCompletada(tarea),
                      ),
                      title: Text(
                        tarea.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: tarea.completada
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: (tarea.cantidadFrecuencia != null &&
                              tarea.unidadFrecuencia != null)
                          ? Text(
                              "Cada ${tarea.cantidadFrecuencia} ${tarea.unidadFrecuencia}",
                              style: const TextStyle(fontSize: 13),
                            )
                          : null,
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

            // BOTÓN AÑADIR TAREA
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PantallaNuevaTarea(areaId: widget.area.id!),
                    ),
                  );
                  _loadTareas();
                },
              ),
            ),

            const SizedBox(height: 12),

            // IMAGEN DEL ÁREA
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

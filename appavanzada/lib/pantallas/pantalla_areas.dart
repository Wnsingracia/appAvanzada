import 'package:appavanzada/pantallas/pantalla_configuracion.dart';
import 'package:appavanzada/pantallas/pantalla_tareas_completas.dart';
import 'package:appavanzada/pantallas/pantalla_tareas_pendientes.dart';
import 'package:flutter/material.dart';
import 'pantalla_selecion_area.dart';
import 'pantalla_nueva_area.dart';
import 'pantalla_infoArea.dart';
import '../models/area.dart';
import '../db/database_helper.dart';

class PantallaAreas extends StatefulWidget {
  const PantallaAreas({super.key});

  @override
  State<PantallaAreas> createState() => _PantallaAreasState();
}

class _PantallaAreasState extends State<PantallaAreas> {
  List<Area> _areas = [];

  

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final loaded = await DatabaseHelper.instance.getAreas();

    if (!mounted) return;

    if (loaded.isEmpty) {
      // Insertar área por defecto solo 1 vez
      

      final reloaded = await DatabaseHelper.instance.getAreas();
      setState(() => _areas = reloaded);
    } else {
      setState(() => _areas = loaded);
    }
  }

  void _showAreaOptions(Area area) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaNuevaArea(
                        areaNombre: area.name,
                        tipo: area.tipo,
                        isCustom: true,
                        originalName: area.name,
                      ),
                    ),
                  ).then((_) => _loadAreas());
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_vert),
                title: const Text('Reordenar'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función reordenar pendiente')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await DatabaseHelper.instance.deleteArea(area.id!);
                  _loadAreas();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayAreas = _areas;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFF0095FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: Text(
                  'Areas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Lista de áreas
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.9,
                  children: List.generate(displayAreas.length + 1, (index) {
                    final isPlus = index == displayAreas.length;

                    // Botón agregar área
                    if (isPlus) {
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PantallaSelecionArea(),
                                    ),
                                  );
                                  _loadAreas();
                                },
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 72,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Mostrar áreas de la DB
                    final area = displayAreas[index];

                    final imageUrl = area.imageUrlForArea(area.name);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InfoArea(area: area),
                          ),
                        );
                      },
                      onLongPress: () => _showAreaOptions(area),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  area.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showAreaOptions(area),
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(color: Color(0xFF0095FF)),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaTareasCompletas(),
                    ),
                  );
                },
                icon: const Icon(Icons.check_box, color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PantallaTareasPendientes()),
                  );
                },
                icon: const Icon(Icons.view_list,
                    color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Configuracion()),
                  );
                },
                icon: const Icon(Icons.settings,
                    color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

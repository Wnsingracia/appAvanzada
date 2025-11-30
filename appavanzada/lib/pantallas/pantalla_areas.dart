import 'package:flutter/material.dart';
import 'pantalla_selecion_area.dart';
import 'pantalla_nueva_area.dart';
import '../services/area_storage.dart';

class PantallaAreas extends StatefulWidget {
  const PantallaAreas({super.key});

  @override
  State<PantallaAreas> createState() => _PantallaAreasState();
}

class _PantallaAreasState extends State<PantallaAreas> {
  final AreaStorage _storage = AreaStorage();
  List<Area> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final loaded = await _storage.loadAreas();
    if (!mounted) return;
    setState(() {
      _areas = loaded;
    });
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
                  // Abrir pantalla de edición, pasando originalName
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
                  // Placeholder: reordenar no implementado ahora
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función reordenar pendiente')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _storage.deleteArea(area.name);
                  if (!mounted) return;
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
    // default tiles (if no areas saved yet) - keep a couple examples
    final defaults = [
      Area(name: 'Sala de estar', tipo: 0, imageSeed: 'sala'),
      Area(name: 'Comedor', tipo: 0, imageSeed: 'comedor'),
    ];

    final displayAreas = _areas.isEmpty ? defaults : _areas;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Curved blue header
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

            // Grid of area cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.9,
                  children: List.generate(displayAreas.length + 1, (index) {
                    final isPlus = index == displayAreas.length;
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
                                  // abrir pantalla de selección y recargar cuando vuelva
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PantallaSelecionArea()),
                                  );
                                  _loadAreas();
                                },
                                child: const Center(
                                  child: Icon(Icons.add, size: 72, color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }

                    final area = displayAreas[index];
                    final imageUrl = area.imageSeed != null
                        ? 'https://picsum.photos/seed/${area.imageSeed}/400/250'
                        : 'https://picsum.photos/seed/area$index/400/250';

                    return GestureDetector(
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
                                child: Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: Text(area.name, style: const TextStyle(fontSize: 14))),
                              IconButton(
                                onPressed: () => _showAreaOptions(area),
                                icon: const Icon(Icons.more_vert),
                              )
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

      // Bottom navigation blue bar
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF0095FF),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.check_box, color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.view_list, color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

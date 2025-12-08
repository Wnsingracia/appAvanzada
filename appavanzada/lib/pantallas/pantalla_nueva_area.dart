import 'package:appavanzada/pantallas/pantalla_areas.dart';
import 'package:flutter/material.dart';
import '../models/area.dart';
import '../db/database_helper.dart';

class PantallaNuevaArea extends StatefulWidget {
  final String areaNombre;
  final int tipo; // 0 Dentro, 1 Fuera, 2 Copiar
  final bool isCustom;
  final String? originalName; // si no es null → edición

  const PantallaNuevaArea({
    super.key,
    required this.areaNombre,
    required this.tipo,
    this.isCustom = false,
    this.originalName,
  });

  @override
  State<PantallaNuevaArea> createState() => _PantallaNuevaAreaState();
}

class _PantallaNuevaAreaState extends State<PantallaNuevaArea> {
  late TextEditingController _controller;
  final db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.areaNombre);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _controller.text;
    final imageUrl = _imageForArea(name);
    final tabs = ['Dentro', 'Fuera', 'Copiar'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: Text(widget.originalName == null ? 'Nueva Área' : 'Editar Área'),
        actions: [
          TextButton(
            onPressed: () async {
              final finalName = _controller.text.trim();

              if (finalName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un nombre para el área'),
                  ),
                );
                return;
              }

              await _saveArea(finalName);
            },
            child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 103, 179, 255),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre del área', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 6),

                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: Container(
                      width: 260,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image,
                              size: 56,
                              color: Colors.black26,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tabs
            Row(
              children: List.generate(3, (i) {
                final isSel = widget.tipo == i;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: isSel ? Colors.blue[600] : Colors.blue[400],
                    child: Center(
                      child: Text(
                        tabs[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: [
                  const Divider(height: 1),
                  _areaTile('Cocina', name),
                  _areaTile('Sala de Estar', name),
                  _areaTile('Comedor', name),
                  _areaTile('Dormitorio', name),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _areaTile(String name, String selected) {
    final isSelected = name.toLowerCase() == selected.toLowerCase();
    return Container(
      color: isSelected ? Colors.blue[700] : Colors.blue[400],
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        onTap: () {
          setState(() {
            _controller.text = name;
          });
        },
      ),
    );
  }

  String? _imageForArea(String name) {
    final n = name.toLowerCase();
    if (n.contains('comedor'))
      return 'https://planner5d.com/blog/content/images/2025/04/comedor.negro.moderno.jpg';
    if (n.contains('sala'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIMSPRKFfVsCtWkgx8mNgJvr4FVN6JIeZFJQ&s';
    if (n.contains('cocina'))
      return 'https://st.hzcdn.com/simgs/65419c56074741bf_14-8315/home-design.jpg';
    if (n.contains('dormitorio'))
      return 'https://content.elmueble.com/medio/2025/04/01/dormitorio-con-cabecero-de-obra-00560141_2bbe7015_00560141_250401120859_2000x1333.webp';
    if (n.contains('jard'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRA5C8z0O7wLEKqRGhE3D5LbWb07hL4Dwxj4A&s';
    if (n.contains('garaj'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTUTCBzg8sMF-2cTFNzb6U9lj2DkCyzxYkpQ&s';
    if (n.contains('baño'))
      return 'https://inspirame.corona.co/wp-content/uploads/2023/08/productos-lanzamiento-Corona-3-1024x614.jpg';
    if (n.contains('terraza'))
      return 'https://st.hzcdn.com/simgs/54d10a2e05cfcd6d_14-7361/home-design.jpg';
    if (n.contains('patio'))
      return 'https://st.hzcdn.com/simgs/dec122f30f1444cb_4-2239/contemporaneo-patio.jpg';
    if (n.isEmpty) return null;
    return null;
  }

  String _seedForName(String name) {
    if (name.isEmpty) return 'area';
    final cleaned = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleaned.isEmpty) return 'area';
    return cleaned.substring(0, cleaned.length.clamp(1, 12));
  }

  Future<void> _saveArea(String finalName) async {
    final area = Area(
      name: finalName,
      tipo: widget.tipo,
      imageSeed: _seedForName(finalName),
    );

    if (widget.originalName == null) {
      // Crear nueva área
      await db.insertArea(area);
    } else {
      // Editar área existente
      await db.updateArea(area);
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaAreas(),
      ),
    ); // volver 1 pantalla
  }
}

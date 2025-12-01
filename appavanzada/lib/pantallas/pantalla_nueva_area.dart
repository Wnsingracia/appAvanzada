import 'package:flutter/material.dart';
import '../services/area_storage.dart';
import '../models/area.dart';

class PantallaNuevaArea extends StatefulWidget {
  final String areaNombre;
  final int tipo; // 0 Dentro, 1 Fuera, 2 Copiar
  final bool isCustom;
  final String? originalName; // si se pasa, indica edición en vez de creación

  const PantallaNuevaArea({super.key, required this.areaNombre, required this.tipo, this.isCustom = false, this.originalName});

  @override
  State<PantallaNuevaArea> createState() => _PantallaNuevaAreaState();
}

class _PantallaNuevaAreaState extends State<PantallaNuevaArea> {
  late TextEditingController _controller;

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
    // Use the controller text as the single source of truth so the user
    // can change the selection here even if the screen was opened with a preset name.
    final name = _controller.text;
    final imageUrl = _imageForArea(name);
    final tabs = ['Dentro', 'Fuera', 'Copiar'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: const Text('Nueva Area'),
        actions: [
          TextButton(
            onPressed: () async {
              final finalName = widget.isCustom ? _controller.text.trim() : _controller.text.trim();
              if (finalName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un nombre para la área')));
                return;
              }
              // Llamar a la función asíncrona separada que hace el await y usa context después
              _saveAreaAndClose(finalName);
            },
            child: const Text('CREAR', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre del area', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                // Always allow editing the name here so the user can change
                // the selection (e.g. change from 'Baño' to 'Comedor').
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(border: UnderlineInputBorder()),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 260,
                    height: 140,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey[200]),
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 56, color: Colors.black26),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          // Tabs row
          Row(
            children: List.generate(3, (i) {
              final isSel = widget.tipo == i;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: isSel ? Colors.blue[600] : Colors.blue[400],
                  child: Center(child: Text(tabs[i], style: const TextStyle(color: Colors.white))),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),
          // Areas list with selected highlighted
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
        ],
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
    if (n.contains('comedor')) return 'https://picsum.photos/seed/comedor/600/300';
    if (n.contains('sala')) return 'https://picsum.photos/seed/sala/600/300';
    if (n.contains('cocina')) return 'https://picsum.photos/seed/cocina/600/300';
    if (n.contains('dormitorio')) return 'https://picsum.photos/seed/dormitorio/600/300';
    if (n.contains('jard')) return 'https://picsum.photos/seed/jardin/600/300';
    if (n.contains('garaj')) return 'https://picsum.photos/seed/garaje/600/300';
    if (n.isEmpty) return null;
    return 'https://picsum.photos/seed/area/600/300';
  }

  String _seedForName(String name) {
    if (name.isEmpty) return 'area';
    // Limpiar el nombre para dejar solo letras ascii y números
    final cleaned = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleaned.isEmpty) return 'area';
    final end = cleaned.length.clamp(1, 12);
    return cleaned.substring(0, end);
  }
  
  Future<void> _saveAreaAndClose(String finalName) async {
    // Crear objeto Area y guardarlo
    final Area area = Area(name: finalName, tipo: widget.tipo, imageSeed: _seedForName(finalName));
    final storage = AreaStorage();
    if (widget.originalName != null && widget.originalName!.isNotEmpty) {
      await storage.updateArea(widget.originalName!, area);
    } else {
      await storage.addArea(area);
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

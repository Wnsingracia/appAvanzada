import 'package:flutter/material.dart';
import '../models/area.dart'; // Modelo Area
import '../db/database_helper.dart'; // Base de datos

// Pantalla para crear una nueva área o editar una existente
class PantallaNuevaArea extends StatefulWidget {
  final String areaNombre; // Nombre inicial o existente del área
  final int tipo; // Tipo del área: 0 Dentro, 1 Fuera, 2 Copiar
  final bool isCustom; // Indica si es un área personalizada
  final String? originalName; // Si no es null → edición de área existente

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
  late TextEditingController _controller; // Controlador para el TextField
  final db = DatabaseHelper.instance; // Instancia de la base de datos

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador con el nombre del área
    _controller = TextEditingController(text: widget.areaNombre);
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _controller.text; // Nombre actual en el TextField
    final imageUrl = _imageForArea(name); // Obtener URL de imagen según nombre
    final tabs = ['Dentro', 'Fuera', 'Copiar']; // Tipos de área

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: Text(widget.originalName == null ? 'Nueva Área' : 'Editar Área'),
        actions: [
          // Botón GUARDAR
          TextButton(
            onPressed: () async {
              final finalName = _controller.text.trim();

              if (finalName.isEmpty) {
                // Validación: nombre obligatorio
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un nombre para el área')),
                );
                return;
              }

              await _saveArea(finalName); // Guardar área en base de datos
            },
            child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 103, 179, 255), // Fondo azul claro
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- Input de nombre del área ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre del área', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 6),

                  TextField(
                    controller: _controller, // Controlador del nombre
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (_) => setState(() {}), // Actualizar vista al escribir
                  ),

                  const SizedBox(height: 40),

                  // --- Vista previa de la imagen del área ---
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
                          : const Icon(Icons.image, size: 56, color: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- Tabs para seleccionar tipo de área ---
            Row(
              children: List.generate(3, (i) {
                final isSel = widget.tipo == i; // Verificar si es el tipo seleccionado
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

            // --- Lista de sugerencias de áreas comunes ---
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

  // --- Widget para cada área sugerida ---
  Widget _areaTile(String name, String selected) {
    final isSelected = name.toLowerCase() == selected.toLowerCase();
    return Container(
      color: isSelected ? Colors.blue[700] : Colors.blue[400],
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        onTap: () {
          // Al tocar, se actualiza el TextField con el nombre seleccionado
          setState(() {
            _controller.text = name;
          });
        },
      ),
    );
  }

  // --- Obtener imagen según nombre del área ---
  String? _imageForArea(String name) {
    final n = name.toLowerCase();
    if (n.contains('comedor')) return 'https://planner5d.com/blog/content/images/2025/04/comedor.negro.moderno.jpg';
    if (n.contains('sala')) return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIMSPRKFfVsCtWkgx8mNgJvr4FVN6JIeZFJQ&s';
    if (n.contains('cocina')) return 'https://st.hzcdn.com/simgs/65419c56074741bf_14-8315/home-design.jpg';
    if (n.contains('dormitorio')) return 'https://content.elmueble.com/medio/2025/04/01/dormitorio-con-cabecero-de-obra-00560141_2bbe7015_00560141_250401120859_2000x1333.webp';
    if (n.contains('jard')) return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRA5C8z0O7wLEKqRGhE3D5LbWb07hL4Dwxj4A&s';
    if (n.contains('garaj')) return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTUTCBzg8sMF-2cTFNzb6U9lj2DkCyzxYkpQ&s';
    if(n.contains('baño')) return 'https://inspirame.corona.co/wp-content/uploads/2023/08/productos-lanzamiento-Corona-3-1024x614.jpg';
    if(n.contains('terraza')) return 'https://st.hzcdn.com/simgs/54d10a2e05cfcd6d_14-7361/home-design.jpg';
    if(n.contains('patio')) return 'https://st.hzcdn.com/simgs/dec122f30f1444cb_4-2239/contemporaneo-patio.jpg';
    if (n.isEmpty) return null;
    return null;
  }

  // --- Generar semilla para imagen basada en nombre ---
  String _seedForName(String name) {
    if (name.isEmpty) return 'area';
    final cleaned = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleaned.isEmpty) return 'area';
    return cleaned.substring(0, cleaned.length.clamp(1, 12));
  }

  // --- Guardar área en base de datos ---
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

    Navigator.of(context).pop(); // Volver a la pantalla anterior
  }
}

// --- Resumen de la página ---
// Esta pantalla permite al usuario crear una nueva área o editar una existente.
// - El usuario puede ingresar o seleccionar un nombre de área.
// - Se muestra una imagen representativa según el nombre.
// - Se pueden elegir los tipos: Dentro, Fuera o Copiar.
// - Permite guardar el área en la base de datos o actualizar una existente.

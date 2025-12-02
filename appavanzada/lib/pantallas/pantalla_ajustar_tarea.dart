import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/tarea.dart';
import 'pantalla_estado_tarea.dart';

class PantallaAjustarTarea extends StatefulWidget {
  final int areaId;
  final String nombreTarea;

  const PantallaAjustarTarea({
    super.key,
    required this.areaId,
    required this.nombreTarea,
  });

  @override
  State<PantallaAjustarTarea> createState() => _PantallaAjustarTareaState();
}

class _PantallaAjustarTareaState extends State<PantallaAjustarTarea> {
  int cantidad = 5;
  String unidad = "Dias"; // Dias - Semanas - Meses

  void aumentar() {
    setState(() {
      cantidad++;
    });
  }

  void disminuir() {
    setState(() {
      if (cantidad > 1) cantidad--;
    });
  }

  Future<void> guardarFrecuencia() async {
    // Creamos la tarea completa con frecuencia y la guardamos en la base de datos
    final tarea = Tarea(
      areaId: widget.areaId,
      nombre: widget.nombreTarea,
      cantidadFrecuencia: cantidad,
      unidadFrecuencia: unidad,
      completada: false,
      ultimaFecha: null,
    );

    final idGenerado = await DatabaseHelper.instance.insertTarea(tarea);

    final tareaGuardada = Tarea(
      id: idGenerado,
      areaId: tarea.areaId,
      nombre: tarea.nombre,
      cantidadFrecuencia: tarea.cantidadFrecuencia,
      unidadFrecuencia: tarea.unidadFrecuencia,
      completada: tarea.completada,
      ultimaFecha: tarea.ultimaFecha,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaEstadoTarea(tarea: tareaGuardada),
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
          "Ajustar Tarea",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            widget.nombreTarea,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Cantidad
                Expanded(
                  child: Column(
                    children: [
                      const Text("Frecuencia"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: disminuir,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            cantidad.toString(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: aumentar,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Unidad: Dias / Semanas / Meses
                Expanded(
                  child: Column(
                    children: [
                      const Text("Unidad"),
                      DropdownButton<String>(
                        value: unidad,
                        items: ["Dias", "Semanas", "Meses"]
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            unidad = v!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0095FF),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: guardarFrecuencia,
            child: const Text(
              "¡SE VE BIEN!",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
